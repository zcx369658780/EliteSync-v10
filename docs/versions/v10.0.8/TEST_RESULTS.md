# v10.0.8 实际执行退出码

每个标签只代表该次源码/范围，不能累加次数声称全量通过。stdout、stderr、退出码和原始/公开hash见 [安全原证索引](evidence/INDEX.json)。失败原件保留本地；core-first公开副本仅脱敏SQL中的密码hash。详细修复与业务证据见 [执行报告](EXECUTION_REPORT.md)。

| 标签 | exit |
|---|---|
| `analyze-final` | 0 |
| `analyze-final02` | 2 |
| `analyze-final03` | 0 |
| `analyze-first` | 0 |
| `build-fifth` | 0 |
| `build-first` | 0 |
| `build-fourth` | 0 |
| `build-second` | 0 |
| `build-third` | 0 |
| `consent-policy-first` | 0 |
| `core-first` | 2 |
| `core-fourth` | 0 |
| `core-second` | 2 |
| `core-third` | 2 |
| `flutter-card-first` | 1 |
| `flutter-format` | 0 |
| `flutter-me` | 0 |
| `flutter-related-02` | 1 |
| `flutter-related-03` | 0 |
| `flutter-related-final` | 0 |
| `flutter-related-final02` | 0 |
| `flutter-related-final03` | 0 |
| `install-fifth` | 0 |
| `install-first` | 0 |
| `install-fourth` | 0 |
| `install-second` | 0 |
| `php-current-run-all-terminal` | 0 |
| `php-current-run-guard` | 0 |
| `php-independent-exclusion` | 0 |
| `php-readiness-contract-repaired` | 1 |
| `php-readiness-contract-repaired02` | 0 |
| `php-regression-fifth` | 1 |
| `php-regression-first` | 2 |
| `php-regression-fourth` | 0 |
| `php-regression-second` | 1 |
| `php-regression-sixth` | 0 |
| `php-regression-third` | 0 |
| `php-round-publish-notice` | 0 |
| `policy-red` | 2 |

最终较宽PHP相关回归146项/1457断言/2 vendor deprecations，exit0；不是后端全套。Flutter最终两次相关41项和30项各exit0、范围不同；全范围analyze No issues found/exit0。全量Flutter本版NOT_RUN，0.7历史3失败及原始exit1不重写。

format-last、format-me缺独立退出码回执；syntax-first只记录checked/bad，不伪填exit0。
