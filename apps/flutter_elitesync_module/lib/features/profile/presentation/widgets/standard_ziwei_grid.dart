import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

enum ZiweiGridViewMode { sanhe, flyingStar, sihua }

class StandardZiweiGrid extends StatelessWidget {
  const StandardZiweiGrid({
    super.key,
    required this.palaces,
    required this.lifePalace,
    required this.bodyPalace,
    required this.bazi,
    this.fourTransformations = const [],
    this.flyingStarLines = const [],
    this.mingGongFlyingStarCandidate = const <String, dynamic>{},
    this.viewMode = ZiweiGridViewMode.sanhe,
    this.onPalaceTap,
  });

  final List<dynamic> palaces;
  final String lifePalace;
  final String bodyPalace;
  final String bazi;
  final List<dynamic> fourTransformations;
  final List<dynamic> flyingStarLines;
  final Map<String, dynamic> mingGongFlyingStarCandidate;
  final ZiweiGridViewMode viewMode;
  final ValueChanged<Map<String, dynamic>>? onPalaceTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sortedPalaces = _sortedPalaces(palaces);
    final gridSlots = _gridSlots(sortedPalaces);
    final showSihua = viewMode == ZiweiGridViewMode.sihua;
    final showFlying = viewMode == ZiweiGridViewMode.flyingStar;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = constraints.maxWidth;
        final cellExtent = extent / 4;
        final gridHeight = extent * 1.18;
        return SizedBox(
          key: ValueKey(_gridKeyForMode(viewMode)),
          width: double.infinity,
          height: gridHeight,
          child: Stack(
            children: [
              Column(
                children: List.generate(4, (row) {
                  return Expanded(
                    child: Row(
                      children: List.generate(4, (col) {
                        final palace = gridSlots[row][col];
                        if (palace == null) {
                          return const Expanded(child: SizedBox.expand());
                        }
                        final index = _palaceIndex(palace);
                        final name = astroText(palace['name'], '-');
                        final branch = astroText(palace['branch'], '地支未返回');
                        final mainStars = _mainStarsText(palace);
                        final statusText = _statusMapText(palace);
                        final summaryText = _palaceSummaryText(palace);
                        final secondary = astroList(palace['secondary_stars'])
                            .map((e) => e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .toList(growable: false);
                        final auxiliary = astroList(palace['auxiliary_stars'])
                            .map((e) => e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .toList(growable: false);
                        final isLife = name == lifePalace;
                        final isBody = name == bodyPalace;
                        final sihuaBadges = showSihua
                            ? _sihuaBadgesForPalace(
                                fourTransformations,
                                name,
                                branch,
                              )
                            : const <ZiweiOverlayBadge>[];
                        final candidateBadges = showFlying
                            ? _candidateBadgesForPalace(
                                flyingStarLines,
                                name,
                                branch,
                              )
                            : const <ZiweiOverlayBadge>[];
                        final hasMingGongCandidate =
                            showFlying &&
                            _isMingGongCandidatePalace(
                              mingGongFlyingStarCandidate,
                              name,
                              branch,
                            );
                        final highlight = isLife || isBody;
                        final highlightColor = t.brandPrimary;
                        final background = highlight
                            ? highlightColor.withValues(
                                alpha: isLife ? 0.12 : 0.07,
                              )
                            : t.browseSurface.withValues(alpha: 0.88);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(0.6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleTap(
                                  context,
                                  palace,
                                  highlight,
                                  isLife,
                                  isBody,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(t.spacing.xxs),
                                  decoration: BoxDecoration(color: background),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _TinyBadge(
                                            label: '$index宫',
                                            color: highlight
                                                ? highlightColor
                                                : t.textSecondary,
                                          ),
                                          if (hasMingGongCandidate) ...[
                                            SizedBox(width: t.spacing.xxs),
                                            _TinyBadge(
                                              label: '命飞候选',
                                              color: t.warning,
                                            ),
                                          ],
                                          const Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: t.spacing.xxs),
                                      Text(
                                        branch == '地支未返回'
                                            ? name
                                            : '$name · $branch',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: t.textPrimary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11.2,
                                            ),
                                      ),
                                      SizedBox(height: t.spacing.xxs),
                                      if (sihuaBadges.isNotEmpty)
                                        _OverlayBadgeRow(
                                          badges: sihuaBadges,
                                          candidate: false,
                                        ),
                                      if (sihuaBadges.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      if (candidateBadges.isNotEmpty)
                                        _OverlayBadgeRow(
                                          badges: candidateBadges,
                                          candidate: true,
                                        ),
                                      if (candidateBadges.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      Text(
                                        '主星 $mainStars',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: t.textSecondary,
                                              height: 1.0,
                                              fontSize: 8.4,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: t.spacing.xxs),
                                      if (statusText.isNotEmpty)
                                        Text(
                                          '状态 $statusText',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.brandPrimary
                                                    .withValues(alpha: 0.90),
                                                height: 1.0,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      if (statusText.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      if (secondary.isNotEmpty)
                                        Text(
                                          '辅 ${secondary.join(' / ')}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.brandPrimary
                                                    .withValues(alpha: 0.90),
                                                height: 1.0,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      if (secondary.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      if (auxiliary.isNotEmpty)
                                        Text(
                                          '杂 ${auxiliary.join(' / ')}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textSecondary,
                                                height: 1.0,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      if (auxiliary.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      Expanded(
                                        child: Text(
                                          summaryText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textPrimary,
                                                height: 1.0,
                                                fontSize: 8.1,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Padding(
                    padding: EdgeInsets.all(cellExtent),
                    child: _CenterPanel(
                      lifePalace: lifePalace,
                      bodyPalace: bodyPalace,
                      bazi: bazi,
                    ),
                  ),
                ),
              ),
              if (showFlying && flyingStarLines.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      key: const ValueKey('ziwei-flying-star-overlay-lines'),
                      painter: _ZiweiFlyingStarOverlayPainter(
                        gridSlots: gridSlots,
                        flyingStarLines: flyingStarLines,
                        lifePalace: lifePalace,
                        mingGongFlyingStarCandidate:
                            mingGongFlyingStarCandidate,
                        tokens: t,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleTap(
    BuildContext context,
    Map<String, dynamic> palace,
    bool highlight,
    bool isLife,
    bool isBody,
  ) {
    final cb = onPalaceTap;
    if (cb != null) {
      cb(palace);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final t = sheetContext.appTokens;
        final name = astroText(palace['name'], '-');
        final branch = astroText(palace['branch'], '-');
        final mainStars = _mainStarsText(palace);
        final statusText = _statusMapText(palace);
        final secondary = astroList(palace['secondary_stars'])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false);
        final auxiliary = astroList(palace['auxiliary_stars'])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false);
        final summaryText = _palaceSummaryText(palace);
        final index = _palaceIndex(palace);

        return Container(
          margin: EdgeInsets.only(
            left: t.spacing.sm,
            right: t.spacing.sm,
            bottom: t.spacing.sm,
          ),
          padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.xl),
            border: Border.all(
              color: highlight ? t.brandPrimary : t.browseBorder,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        branch == '-'
                            ? '$name · $index宫'
                            : '$name · $branch · $index宫',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (highlight)
                      Text(
                        isLife ? '命宫' : '身宫',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: t.brandPrimary.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: t.spacing.sm),
                Text(
                  '主星：$mainStars',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (statusText.isNotEmpty) ...[
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    '庙旺陷平得：$statusText',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.brandPrimary.withValues(alpha: 0.90),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                SizedBox(height: t.spacing.sm),
                Text(
                  summaryText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    height: 1.45,
                  ),
                ),
                if (secondary.isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '辅星 / 六吉',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    secondary.join(' / '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                if (auxiliary.isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '杂曜 / 六煞',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    auxiliary.join(' / '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _sortedPalaces(List<dynamic> raw) {
    final list = raw
        .map(_asAstroMap)
        .where((row) => row.isNotEmpty)
        .toList(growable: false);
    final sorted = [...list];
    sorted.sort((a, b) => _palaceIndex(a).compareTo(_palaceIndex(b)));
    return sorted;
  }

  List<List<Map<String, dynamic>?>> _gridSlots(
    List<Map<String, dynamic>> palaces,
  ) {
    Map<String, dynamic>? pick(int index) =>
        index < palaces.length ? palaces[index] : null;
    return [
      [pick(0), pick(1), pick(2), pick(3)],
      [pick(11), null, null, pick(4)],
      [pick(10), null, null, pick(5)],
      [pick(9), pick(8), pick(7), pick(6)],
    ];
  }

  int _palaceIndex(Map<String, dynamic> palace) =>
      (palace['index'] as num?)?.toInt() ?? 0;
}

String _gridKeyForMode(ZiweiGridViewMode mode) {
  switch (mode) {
    case ZiweiGridViewMode.sanhe:
      return 'ziwei-split-grid-sanhe';
    case ZiweiGridViewMode.flyingStar:
      return 'ziwei-split-grid-flying-star';
    case ZiweiGridViewMode.sihua:
      return 'ziwei-split-grid-sihua';
  }
}

class ZiweiOverlayBadge {
  const ZiweiOverlayBadge({
    required this.label,
    required this.color,
    this.star = '',
  });

  final String label;
  final Color color;
  final String star;
}

class _OverlayBadgeRow extends StatelessWidget {
  const _OverlayBadgeRow({required this.badges, required this.candidate});

  final List<ZiweiOverlayBadge> badges;
  final bool candidate;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: badges
          .take(4)
          .map((badge) {
            final label = badge.star.isEmpty
                ? badge.label
                : '${badge.star}${badge.label}';
            return Container(
              key: ValueKey(
                candidate
                    ? 'ziwei-flying-badge-$label'
                    : 'ziwei-sihua-badge-$label',
              ),
              constraints: const BoxConstraints(minWidth: 25, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: candidate ? 0.18 : 0.28),
                border: Border.all(
                  color: badge.color.withValues(alpha: candidate ? 0.82 : 0.92),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: badge.color.withValues(alpha: 0.20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                candidate ? '${badge.label}候' : badge.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: badge.color,
                  fontSize: 10.8,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _ZiweiFlyingStarOverlayPainter extends CustomPainter {
  const _ZiweiFlyingStarOverlayPainter({
    required this.gridSlots,
    required this.flyingStarLines,
    required this.lifePalace,
    required this.mingGongFlyingStarCandidate,
    required this.tokens,
  });

  final List<List<Map<String, dynamic>?>> gridSlots;
  final List<dynamic> flyingStarLines;
  final String lifePalace;
  final Map<String, dynamic> mingGongFlyingStarCandidate;
  final AppThemeTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final centers = _palaceCenters(size);
    final chartCenter = Offset(size.width / 2, size.height / 2);
    final lifeCenter = centers[_normalizePalaceName(lifePalace)];
    final lifeBranch = astroText(
      mingGongFlyingStarCandidate['life_branch'],
      '',
    );

    if (lifeCenter != null) {
      final lifePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = tokens.warning.withValues(alpha: 0.88);
      canvas.drawCircle(lifeCenter, 18, lifePaint);
      if (lifeBranch.isNotEmpty) {
        canvas.drawCircle(
          lifeCenter,
          24,
          lifePaint
            ..strokeWidth = 1.8
            ..color = tokens.warning.withValues(alpha: 0.52),
        );
      }
    }

    var lineIndex = 0;
    for (final item in flyingStarLines.take(10)) {
      final line = _asAstroMap(item);
      if (line.isEmpty) continue;
      final target = _lineTarget(line, centers);
      if (target == null) continue;
      final marker = _transformMarker(line);
      final color = _transformColor(marker, tokens);
      final offset = (lineIndex % 3 - 1) * 12.0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.78);
      final haloPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.58);
      final path = Path()
        ..moveTo(chartCenter.dx, chartCenter.dy)
        ..quadraticBezierTo(
          (chartCenter.dx + target.dx) / 2 + offset,
          (chartCenter.dy + target.dy) / 2 - 18,
          target.dx,
          target.dy,
        );
      canvas.drawPath(path, haloPaint);
      canvas.drawPath(path, paint);
      _drawArrowHead(canvas, chartCenter, target, color);
      canvas.drawCircle(
        target,
        8,
        Paint()..color = Colors.white.withValues(alpha: 0.84),
      );
      canvas.drawCircle(
        target,
        6,
        Paint()..color = color.withValues(alpha: 0.90),
      );
      _drawCandidateLineLabel(
        canvas,
        Offset(
          (chartCenter.dx + target.dx) / 2 + offset,
          (chartCenter.dy + target.dy) / 2 - 22,
        ),
        marker.isEmpty ? '候选' : '$marker候选',
        color,
      );
      lineIndex++;
    }
  }

  Map<String, Offset> _palaceCenters(Size size) {
    final centers = <String, Offset>{};
    final cellWidth = size.width / 4;
    final cellHeight = size.height / 4;
    for (var row = 0; row < gridSlots.length; row++) {
      for (var col = 0; col < gridSlots[row].length; col++) {
        final palace = gridSlots[row][col];
        if (palace == null) continue;
        final center = Offset(
          col * cellWidth + cellWidth / 2,
          row * cellHeight + cellHeight / 2,
        );
        final name = _normalizePalaceName(astroText(palace['name'], ''));
        final branch = astroText(palace['branch'], '');
        if (name.isNotEmpty) centers[name] = center;
        if (branch.isNotEmpty) centers[branch] = center;
      }
    }
    return centers;
  }

  Offset? _lineTarget(Map<String, dynamic> line, Map<String, Offset> centers) {
    final palace = _normalizePalaceName(
      astroText(line['line_end_palace'], astroText(line['to_palace'], '')),
    );
    final branch = astroText(line['branch'], '');
    return centers[palace] ?? centers[branch];
  }

  @override
  bool shouldRepaint(covariant _ZiweiFlyingStarOverlayPainter oldDelegate) {
    return oldDelegate.flyingStarLines != flyingStarLines ||
        oldDelegate.lifePalace != lifePalace ||
        oldDelegate.mingGongFlyingStarCandidate !=
            mingGongFlyingStarCandidate ||
        oldDelegate.tokens != tokens;
  }
}

Map<String, dynamic> _asAstroMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return const <String, dynamic>{};
}

String _mainStarsText(Map<String, dynamic> palace) {
  final stars = astroList(palace['main_stars'])
      .map((star) => star.toString().trim())
      .where((star) => star.isNotEmpty)
      .toList(growable: false);
  if (stars.isNotEmpty) return stars.join('、');
  return astroText(palace['main_star'], '-');
}

String _statusMapText(Map<String, dynamic> palace) {
  final statusMap = _asAstroMap(palace['star_status_map']);
  final labels = statusMap.entries
      .map((entry) {
        final star = entry.key.trim();
        final status = entry.value.toString().trim();
        if (star.isEmpty || status.isEmpty) return '';
        return '$star$status';
      })
      .where((label) => label.isNotEmpty)
      .toList(growable: false);
  return labels.join('、');
}

String _palaceSummaryText(Map<String, dynamic> palace) {
  final raw = astroText(palace['summary'], '').trim();
  if (raw.isNotEmpty && !_hasTechnicalZiweiMarker(raw)) return raw;

  final name = astroText(palace['name'], '-');
  final branch = astroText(palace['branch'], '');
  final stars = _mainStarsText(palace);
  final location = branch.isEmpty ? name : '$name在$branch';
  final starText = stars == '-' ? '主星待补充' : '主星$stars';
  return '$location，$starText；用于关系节奏参考。';
}

List<ZiweiOverlayBadge> _sihuaBadgesForPalace(
  List<dynamic> items,
  String palaceName,
  String branch,
) {
  final normalizedName = _normalizePalaceName(palaceName);
  return items
      .map(_asAstroMap)
      .where((row) {
        final rowPalace = _normalizePalaceName(astroText(row['palace'], ''));
        final rowBranch = astroText(row['branch'], '');
        if (rowPalace.isNotEmpty) return rowPalace == normalizedName;
        return rowPalace == normalizedName ||
            (branch.isNotEmpty && rowBranch.contains(branch));
      })
      .map((row) {
        final marker = _transformMarker(row);
        final star = astroText(row['star'], '');
        if (marker.isEmpty) return null;
        return ZiweiOverlayBadge(
          label: marker,
          star: star,
          color: _transformColor(marker, null),
        );
      })
      .whereType<ZiweiOverlayBadge>()
      .toList(growable: false);
}

List<ZiweiOverlayBadge> _candidateBadgesForPalace(
  List<dynamic> lines,
  String palaceName,
  String branch,
) {
  final normalizedName = _normalizePalaceName(palaceName);
  return lines
      .map(_asAstroMap)
      .where((line) {
        final target = _normalizePalaceName(
          astroText(line['line_end_palace'], astroText(line['to_palace'], '')),
        );
        final lineBranch = astroText(line['branch'], '');
        if (target.isNotEmpty) return target == normalizedName;
        return target == normalizedName ||
            (branch.isNotEmpty && lineBranch.contains(branch));
      })
      .map((line) {
        final marker = _transformMarker(line);
        if (marker.isEmpty) return null;
        return ZiweiOverlayBadge(
          label: marker,
          color: _transformColor(marker, null),
        );
      })
      .whereType<ZiweiOverlayBadge>()
      .toList(growable: false);
}

bool _isMingGongCandidatePalace(
  Map<String, dynamic> candidate,
  String palaceName,
  String branch,
) {
  final status = astroText(candidate['status'], '');
  if (status != 'candidate_visualization') return false;
  final lifePalace = _normalizePalaceName(
    astroText(candidate['life_palace'], ''),
  );
  final lifeBranch = astroText(candidate['life_branch'], '');
  final normalizedName = _normalizePalaceName(palaceName);
  return lifePalace == normalizedName ||
      (branch.isNotEmpty && lifeBranch.contains(branch));
}

String _normalizePalaceName(String value) =>
    value.replaceAll('宫', '').replaceAll(' ', '').trim();

String _transformMarker(Map<String, dynamic> row) {
  final raw = astroText(row['transform'], astroText(row['transform_type'], ''));
  if (raw.contains('禄')) return '禄';
  if (raw.contains('权')) return '权';
  if (raw.contains('科')) return '科';
  if (raw.contains('忌')) return '忌';
  return '';
}

Color _transformColor(String marker, AppThemeTokens? t) {
  switch (marker) {
    case '禄':
      return t?.success ?? const Color(0xFF2E7D32);
    case '权':
      return t?.brandPrimary ?? const Color(0xFF673AB7);
    case '科':
      return t?.info ?? const Color(0xFF1976D2);
    case '忌':
      return t?.error ?? const Color(0xFFC62828);
    default:
      return t?.textSecondary ?? const Color(0xFF6B7280);
  }
}

void _drawArrowHead(Canvas canvas, Offset from, Offset to, Color color) {
  final vector = to - from;
  if (vector.distance < 1) return;
  final direction = vector / vector.distance;
  final normal = Offset(-direction.dy, direction.dx);
  const size = 7.0;
  final p1 = to - direction * size + normal * (size * 0.48);
  final p2 = to - direction * size - normal * (size * 0.48);
  final path = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(p1.dx, p1.dy)
    ..lineTo(p2.dx, p2.dy)
    ..close();
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.70),
  );
}

void _drawCandidateLineLabel(
  Canvas canvas,
  Offset center,
  String label,
  Color color,
) {
  final painter = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        color: color,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        height: 1.0,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final rect = Rect.fromCenter(
    center: center,
    width: painter.width + 12,
    height: painter.height + 7,
  );
  final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
  canvas.drawRRect(
    rrect,
    Paint()..color = Colors.white.withValues(alpha: 0.90),
  );
  canvas.drawRRect(
    rrect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: 0.78),
  );
  painter.paint(
    canvas,
    Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
  );
}

bool _hasTechnicalZiweiMarker(String value) {
  final lower = value.toLowerCase();
  return lower.contains('cece p0') ||
      lower.contains('oracle transcript') ||
      lower.contains('selected ziwei fields') ||
      lower.contains('ziwei_cece') ||
      lower.contains('p0_selected_fields') ||
      lower.contains('not_validated') ||
      value.contains('待校验');
}

class _CenterPanel extends StatelessWidget {
  const _CenterPanel({
    required this.lifePalace,
    required this.bodyPalace,
    required this.bazi,
  });

  final String lifePalace;
  final String bodyPalace;
  final String bazi;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final pillars = _parseBaziPillars(bazi);
    final dayMaster = pillars.isNotEmpty && pillars.length >= 3
        ? _firstChar(pillars[2])
        : '-';
    final dayMasterElement = _elementOfGan(dayMaster);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xxs,
        vertical: t.spacing.xs,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BaziPillarsGrid(pillars: pillars),
          SizedBox(height: t.spacing.xs),
          Text(
            '日主 $dayMaster${dayMasterElement.isEmpty ? '' : '（$dayMasterElement）'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary.withValues(alpha: 0.78),
              fontSize: 8.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaziPillarsGrid extends StatelessWidget {
  const _BaziPillarsGrid({required this.pillars});

  final List<String> pillars;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final items = pillars.length == 4
        ? pillars
        : const ['--', '--', '--', '--'];
    const labels = ['年', '月', '日', '时'];

    return Column(
      children: [
        Row(
          children: List.generate(2, (index) {
            return Expanded(
              child: _BaziPillarCell(label: labels[index], value: items[index]),
            );
          }),
        ),
        SizedBox(height: t.spacing.xxs),
        Row(
          children: List.generate(2, (index) {
            final idx = index + 2;
            return Expanded(
              child: _BaziPillarCell(label: labels[idx], value: items[idx]),
            );
          }),
        ),
      ],
    );
  }
}

class _BaziPillarCell extends StatelessWidget {
  const _BaziPillarCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final stem = value.isNotEmpty ? _firstChar(value) : '-';
    final element = _elementOfGan(stem);
    final accent = _elementColor(element, t);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: t.spacing.xxs),
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xxs,
        vertical: t.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textSecondary,
              fontSize: 7.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 10.4,
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _parseBaziPillars(String bazi) {
  final tokens = bazi
      .split(RegExp(r'\s+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
  if (tokens.length != 4) return const [];
  return tokens;
}

String _firstChar(String value) {
  if (value.isEmpty) return '-';
  final iterator = value.runes.iterator;
  if (!iterator.moveNext()) return '-';
  return String.fromCharCode(iterator.current);
}

String _elementOfGan(String stem) {
  const map = {
    '甲': '木',
    '乙': '木',
    '丙': '火',
    '丁': '火',
    '戊': '土',
    '己': '土',
    '庚': '金',
    '辛': '金',
    '壬': '水',
    '癸': '水',
  };
  return map[stem] ?? '';
}

Color _elementColor(String element, AppThemeTokens t) {
  switch (element) {
    case '木':
      return const Color(0xFF4CAF50);
    case '火':
      return const Color(0xFFF44336);
    case '土':
      return const Color(0xFF9C7B5C);
    case '金':
      return const Color(0xFF7A7E89);
    case '水':
      return const Color(0xFF2196F3);
    default:
      return t.textSecondary;
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.82,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 8.3,
          height: 1.0,
        ),
      ),
    );
  }
}
