# RTC-4543SA & I2C SUBボード

## 概要

* PC-8001 YM2203 FM音源ボード([https://github.com/kuninet/PC8001-YM2203](https://github.com/kuninet/PC8001-YM2203))の汎用I/O(GPIO)端子につなぐサブボードです。
    * 秋月電子「３２ｋＨｚ出力シリアルＲＴＣ基板モジュール」([https://akizukidenshi.com/catalog/g/gK-10722/](https://akizukidenshi.com/catalog/g/gK-10722/))を使用します。

<br>
## サンプルアプリ

srcディレクトリに以下のサンプルアプリがあります。

| ソース名 | 説明 |
| ---- | --- |
| RTC4543\_RD-YM2203.asm | RTC-4543SA日時読み出し機械語サブルーチン<br>(PC-8001 USR関数Call用) |
| RTC4543\_WR-YM2203.asm | RTC-4543SA日時書き込み機械語サブルーチン<br>(PC-8001 USR関数Call用) |

## 参考

* Groveコネクタのフットプリントは以下を使用しています。
    * [https://github.com/KiCad](https://github.com/KiCad)