# R1 实际执行退出码

stdout/stderr与退出码共同读取；首轮append-fixtures打印QueryException但exit0，明确BUSINESS_FAILED，不能写PASS。原记录均保留，安全hash见[r1-evidence/INDEX.json](r1-evidence/INDEX.json)。

| 标签 | exit |
|---|---|
| `analyze-appeal-first` | 0 |
| `analyze-full` | 0 |
| `append-fixtures` | 0 |
| `append-fixtures-corrected` | 0 |
| `build-first` | 0 |
| `concurrent-proof` | 0 |
| `db-start` | 0 |
| `device-pull` | 0 |
| `final-avd-stop` | 0 |
| `final-db-stop` | 0 |
| `final-service-stop` | 0 |
| `flutter-appeal-first` | 1 |
| `flutter-appeal-second` | 1 |
| `flutter-appeal-third` | 0 |
| `install-first` | 0 |
| `migrate` | 1 |
| `migrate-ready` | 0 |
| `php-appeal-first` | 2 |
| `php-appeal-red` | 2 |
| `php-appeal-second` | 0 |
| `restart` | 0 |
| `restore-held` | 0 |
| `source-commit` | 0 |

最终相关PHP31项/367断言/2弃用，Flutter21项，全范围Dart No issues，构建安装exit0。全量套件与其余模块全套NOT_RUN；原0.7历史失败及初始0.8原证不改写。详细业务/修复见[R1报告](R1_EXECUTION_REPORT.md)。
