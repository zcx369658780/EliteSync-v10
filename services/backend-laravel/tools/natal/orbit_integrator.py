"""Generic, independently written Dormand-Prince 5(4) numerical integrator.

This module contains no astronomical model, constants, or data. Numerical error
control does not establish the accuracy of any physical model supplied as rhs.
"""

import math
import operator

import numpy as np


class IntegrationError(RuntimeError):
    """Integration failed; no partial state is exposed as a successful result."""

    def __init__(self, message, statistics):
        super().__init__(message)
        self.statistics = dict(statistics)


def integrate(rhs, t0, y0, t1, rtol=1e-10, atol=1e-12,
              max_step=math.inf, max_steps=100000):
    """Return ``(final_state, statistics)`` after integrating ``dy/dt = rhs(t,y)``.

    State and derivatives must be finite real arrays of identical shape (a scalar
    state is also accepted). ``atol`` may broadcast to that shape; ``rtol`` is a
    positive scalar. The embedded fourth-order estimate controls a weighted RMS
    local error; it is not a bound on global error. ``max_steps`` counts all
    attempted steps, including rejected ones. Every attempt uses seven rhs calls;
    this intentionally does not reuse derivatives across steps (no FSAL cache).

    Invalid arguments raise ValueError. Runtime numerical failures raise
    IntegrationError with counters but without a partial state. Exceptions from
    rhs itself propagate, except floating-point errors are wrapped with counters.
    No dense output or event detection is provided.
    """
    t0, t1, rtol, max_step = map(float, (t0, t1, rtol, max_step))
    if not math.isfinite(t0) or not math.isfinite(t1):
        raise ValueError('times must be finite')
    if not math.isfinite(rtol) or rtol <= 0:
        raise ValueError('rtol must be finite and positive')
    if math.isnan(max_step) or max_step <= 0:
        raise ValueError('max_step must be positive')
    try:
        if isinstance(max_steps, (bool, np.bool_)):
            raise TypeError
        max_steps = operator.index(max_steps)
    except TypeError as exc:
        raise ValueError('max_steps must be a positive integer') from exc
    if max_steps <= 0:
        raise ValueError('max_steps must be a positive integer')
    if not callable(rhs):
        raise ValueError('rhs must be callable')
    if np.iscomplexobj(y0) or np.iscomplexobj(atol):
        raise ValueError('complex states and tolerances are not supported')
    y = np.array(y0, dtype=float, copy=True)
    if y.size == 0 or not np.all(np.isfinite(y)):
        raise ValueError('state must be nonempty and finite')
    try:
        absolute = np.broadcast_to(np.asarray(atol, dtype=float), y.shape)
    except ValueError as exc:
        raise ValueError('atol must broadcast to the state shape') from exc
    if not np.all(np.isfinite(absolute)) or np.any(absolute <= 0):
        raise ValueError('atol must be finite and positive')
    stats = dict(accepted=0, rejected=0, evaluation_count=0, attempted=0,
                 initial_time=t0, final_time=t0)

    def fail(message):
        raise IntegrationError(message, stats)

    def evaluate(time, state):
        if not math.isfinite(time) or not np.all(np.isfinite(state)):
            fail('nonfinite stage time or state')
        stats['evaluation_count'] += 1
        raw = rhs(time, state.copy())
        if np.iscomplexobj(raw):
            fail('complex derivative is not supported')
        try:
            derivative = np.array(raw, dtype=float, copy=True)
        except (TypeError, ValueError) as exc:
            raise IntegrationError('derivative is not a real numeric array', stats) from exc
        if derivative.shape != y.shape or not np.all(np.isfinite(derivative)):
            fail('derivative must be finite and match the state shape')
        return derivative

    if t0 == t1:
        return y, stats
    direction = 1.0 if t1 > t0 else -1.0
    span = abs(t1 - t0)
    if not math.isfinite(span):
        fail('time interval overflows floating point')
    step_size = min(max_step, span / 100.0)
    t = t0
    was_rejected = False
    while t != t1:
        if stats['attempted'] >= max_steps:
            fail('step budget exhausted before endpoint')
        remaining = abs(t1 - t)
        step_size = min(step_size, max_step, remaining)
        h = direction * step_size
        endpoint = step_size == remaining
        next_t = t1 if endpoint else t + h
        if h == 0.0 or next_t == t or not math.isfinite(next_t):
            fail('step size underflow or nonfinite next time')
        stats['attempted'] += 1
        try:
            with np.errstate(over='raise', invalid='raise', divide='raise'):
                k1 = evaluate(t, y)
                k2 = evaluate(t + h / 5, y + h * (k1 / 5))
                k3 = evaluate(t + h * 3 / 10,
                              y + h * (3 / 40 * k1 + 9 / 40 * k2))
                k4 = evaluate(t + h * 4 / 5,
                              y + h * (44 / 45 * k1 - 56 / 15 * k2 + 32 / 9 * k3))
                k5 = evaluate(t + h * 8 / 9,
                              y + h * (19372 / 6561 * k1 - 25360 / 2187 * k2
                                       + 64448 / 6561 * k3 - 212 / 729 * k4))
                k6 = evaluate(next_t,
                              y + h * (9017 / 3168 * k1 - 355 / 33 * k2
                                       + 46732 / 5247 * k3 + 49 / 176 * k4
                                       - 5103 / 18656 * k5))
                candidate = y + h * (35 / 384 * k1 + 500 / 1113 * k3
                                     + 125 / 192 * k4 - 2187 / 6784 * k5
                                     + 11 / 84 * k6)
                k7 = evaluate(next_t, candidate)
                # Fifth-order weights minus embedded fourth-order weights.
                error = h * (71 / 57600 * k1 - 71 / 16695 * k3
                             + 71 / 1920 * k4 - 17253 / 339200 * k5
                             + 22 / 525 * k6 - 1 / 40 * k7)
                scale = absolute + rtol * np.maximum(np.abs(y), np.abs(candidate))
                ratio = np.abs(error) / scale
                # Scaled RMS avoids squaring large ratios directly.
                peak = float(np.max(ratio))
                error_norm = (0.0 if peak == 0.0 else
                              peak * float(np.sqrt(np.mean((ratio / peak) ** 2))))
        except FloatingPointError as exc:
            raise IntegrationError('floating-point failure during step', stats) from exc
        if not math.isfinite(error_norm):
            fail('nonfinite error estimate')
        factor = 10.0 if error_norm == 0.0 else 0.9 * error_norm ** (-0.2)
        factor = min(10.0, max(0.2, factor))
        if error_norm <= 1.0:
            y = candidate
            t = next_t
            stats['accepted'] += 1
            stats['final_time'] = t
            if was_rejected:
                factor = min(1.0, factor)
            was_rejected = False
        else:
            stats['rejected'] += 1
            factor = min(1.0, factor)
            was_rejected = True
        step_size *= factor
    return y, stats
