"""Static candidate for the private Flutter environment; never starts a process.

The selected process-5.0.5 executable resolver dereferences PATHEXT on Windows.
This candidate limits lookup to .EXE; sufficiency is not runtime-proven.
Command scripts and host environment inheritance are not introduced. A later
controller still needs its own qualified image set.
"""


def with_executable_extensions(environment):
    if type(environment) is not dict:
        raise ValueError('Explicit private environment dictionary required')
    result, names = {}, set()
    for key, value in environment.items():
        if (type(key) is not str or not key or '=' in key or type(value) is not str
                or any(char in key + value for char in '\0\r\n')):
            raise ValueError('Invalid private environment entry')
        folded = key.casefold()
        if folded in names:
            raise ValueError('Duplicate Windows environment name')
        names.add(folded)
        if folded == 'flutter_already_locked':
            raise ValueError('Normal Flutter cache lock is required')
        if folded == 'pathext':
            if value != '.EXE':
                raise ValueError('Only the explicitly selected .EXE extension is allowed')
            continue
        result[key] = value
    result['PATHEXT'] = '.EXE'
    return result
