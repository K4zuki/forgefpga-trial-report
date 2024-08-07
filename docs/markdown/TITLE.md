# まえがき {-}

## このドキュメントは何 {-}

この本は、~~ルネサス~~ダイアログセミコンダクターの小規模FPGA「ForgeFPGA」**SLG47910**の評価キットを購入し、簡単なプロジェクトを作ってデバッグするまでをまとめたドキュメントです。
2021年に魅力的な内容をプレスリリース[^1]したあと3年にわたって続報がなく、「_幻FPGA_」とか
「_Forge**T**FPGA_」など散々揶揄されてきた[^2][^3] ForgeFPGAですが、
2024年6月、突然Mouser/Digikey/直販サイトで評価キットが入手可能になりました。筆者も、ちょうど夏コミに間に合う時期ということで、小さい方のキットを
Mouserで購入して試すことにしました。あいにくICはまだ入手できず、キットに付属するサンプルも10個しかないので、自作基板は作りません。

データシート[^4]によると、CPUなどからビットストリームを直接流し込んだり、SPIフラッシュROMからロードさせることができるようなので、一通り調査してみたいと思います。

## おことわり {-}

筆者はMac版とWindows版両方の環境を使っていますが、Windows版のみについて解説します。

[^1]: <https://www.renesas.com/jp/ja/about/press-room/renesas-enters-fpga-market-first-ultra-low-power-low-cost-family-addressing-low-density-high-volume>

[^2]: <https://community.renesas.com/analog-products/f/greenpak-greenfet/28390/forgefpga-datasheets/108088#108088>

[^3]: <https://community.renesas.com/analog-products/f/greenpak-greenfet/29049/forgefpga-availability/109444#109444>

[^4]: <https://www.renesas.com/us/en/document/dst/slg47910-datasheet?r=25546631>

## 参考リンク集 {.unnumbered #reference-links}

- [[SLG47910V 製品ページ]{#slg47910-product-page}](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg47910-1k-lut-forgefpga)
- [[SLG47910V データシート]{#slg47910-datasheet-download}](https://www.renesas.com/us/en/document/dst/slg47910-datasheet?r=25546631)
- [[ForgeFPGAコンフィグレーションガイド]{#forgefpga-configuration-guide-download}](https://www.renesas.com/us/en/document/mah/forgefpga-configuration-guide?r=25546631)

- [[SLG7EVBFORGE（評価ボード） 製品ページ]{#evalboard-product-page}](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg7evbforge-1k-lut-forgefpga-evaluation-board)
- [[SLG7EVBFORGE（評価ボード） マニュアル]{#evalboard-manual}](https://www.renesas.com/us/en/document/mah/forgefpga-evaluation-board-r20-users-manual?r=25546646)

- [[SLG7EVBFORGE（評価ボード） Mouser販売ページ]{#evalboard-mouser}](https://www.mouser.jp/ProductDetail/Renesas-Dialog/SLG7EVBFORGE?qs=2wMNvWM5ZX5HC1b2oIQaEg%3D%3D)
- [[SLG7EVBFORGE（評価ボード） DigiKey販売ページ]{#evalboard-digikey}](https://www.digikey.jp/en/products/detail/SLG7EVBFORGE/1695-SLG7EVBFORGE-ND/22972057)

- [[開発環境ダウンロードページ]{#ide-download-page}](https://www.renesas.com/us/en/software-tool/go-configure-software-hub)
- [[開発環境マニュアル]{#ide-manual-download}](https://www.renesas.com/us/en/document/mat/go-configure-software-hub-user-guide)
- [[開発環境 Windows版]{#ide-windows-download}](https://www.renesas.com/us/en/document/sws/go-configure-software-hub-windows-64-bit)

- [[線形帰還シフトレジスタ LFSRのまとめ、FPGAの Verilog HDLでの実装例]{#lfsr-verilog-ref}](http://www.neko.ne.jp/~freewing/fpga/lfsr_verilog/)
- [[FPGAでVGA出力 - モノ創りで国造りを]{#vga-verilog-ref}](https://yuji2yuji.hatenablog.com/entry/2019/08/21/144446)

\toc

# ForgeFPGA SLG47910 の主な仕様

[@tbl:slg47910-spec]に主な仕様一覧を示します。0.4mmピッチ24ピンQFN(3ミリ角)、この内最大19ピンをIOに使えます。電源はIOとコアで**2系統**必要です。
また、IOレベルは低めの**2.5Vまたは1.8V系**で動作します。Arduinoやラズパイを直結するとたぶん壊れます。
ビットストリーム（内部結線情報）のSPIフラッシュからのロード、SPIホストからの書き込み、内蔵ワンタイムROMからのロードができます。SPIは専用ではなく、GPIOと共有です。当然ですがフラッシュも1.8V動作品が必要です。
筆者は秋月で売っているもの^[<https://akizukidenshi.com/catalog/g/g118046/>]を入手済ですが、ROMライターの類を持っていないので、まだ実験には至っていません。

::: rmnote

- ピン配置DS
- SPIと共有

:::

::: {.table noheader=true}

|    パッケージ    | 0.4mmピッチ24ピンQFN（EPなし）                  |
|:-----------:|----------------------------------------|
| 動作電圧（VDDIO） | 1.71 - **2.75**V (LVCMOS18 / LVCMOS25) |
| 動作電圧（VDDC）  | 1.1V &plusmn; 10%                      |
|  ５ビットLUT数   | 1120                                   |
|    DFF数     | 1120                                   |
|   動作温度範囲    | -40 - 85 &#8451;                       |
|  内蔵クロック周波数  | 50MHz                                  |
|   最大GPIO数   | 19                                     |
|  最大GPIO周波数  | 300MHz                                 |

Table: SLG47910 Spec {#tbl:slg47910-spec}
:::

![内部ブロック図(データシート抜粋)](images/block_diagram.png){#fig:internal-diagram width=150mm}

::: rmnote

Package:
QFN-24

Description:
The SLG47910 provides a small, low power component for common FPGA applications. The user creates their circuit design by programming the One Time Programmable (OTP) Non-Volatile Memory (NVM) to configure the interconnect logic, the IO pins, and the macrocells of the SLG47910. This highly versatile device allows a wide variety of FPGA applications to be designed within a very small, low power integrated circuit. The macrocells in the device include the following:
Dense Array of Configurable Logic:
1120 5-bit LUTs;
1120 DFFs;
5 kb distributed memory;
32 kb BRAM;
Configurable through NVM and/or SPI interface;
50 MHz On-Chip Oscillator:
Phase-locked Loop (PLL):
Input from external source or internal On-Chip Oscillator;
Power Supply:
VDDIO: 1.71 V to 2.75 V;
VDDCore: 1.1 V ± 10%;
Power-On-Reset (POR);
GPIO Count
19 GPIOs
Operating Temperature Range: -40 °C to 85 °C

:::

# 設計ソフト

## ダウンロード（Windows版）

まず設計ソフトを入手します。参考リンク集から[ダウンロードページ](#ide-download-page)に行き、[Windows版](#ide-windows-download)を入手します。
ダイアログの頃とは異なり、ダウンロードには[ユーザ登録とログインが必要]{.underline}です。また、過去バージョンへのアクセスもなさそうです。そういうとこやぞ&reg;

![設計ソフトダウンロードページ](images/software_download_page.png){#fig:software-download-page width=150mm}

::: rmnote

- HEX出力が行方不明

:::

# 評価ボード

評価ボードを入手して実動作を見てみました。

## 購入（Mouserの場合）

筆者はMouserから評価ボードを購入しました。商品ページには[リンク集](#evalboard-mouser)から飛べます。

![SLG7EVBFORGE（評価ボード） Mouser販売ページ](images/evalboard-mouser-page.png){#fig:screenshot-mouser-page width=150mm}

\newpage

### ICの単体購入はできな...くはない（買えるとは言っていない）

SLG47910チップ単体の直販購入はまだできず、サンプル請求しかありません（将来的に直販が開放されるかどうかも不明）。
ルネのポリシーとしては、Gmailなどのメールアドレスで登録されたユーザからのサンプル請求を拒否するようです。そういうとこやぞ&reg;

ルネの製品ページからAVNETの商品ページに飛べますが、[フルリール5000個]{.underline}でしか購入できません。なお、執筆時点(2024年8月)では在庫がありません。

![ルネサス製品ページ（直販メニュー）](images/buy-from-avnet.png){#fig:buy-from-avnet width=130mm}

![AVNET商品ページ（在庫なし）](images/buy-from-avnet-2.png){#fig:buy-from-avnet-2 width=130mm}

\newpage

### 配送業者はUPSを選択...何故か名古屋に飛ばされる

# VGAランダム出力プロジェクトを作ってみる

[main.v](../vga_random/ffpga/src/main.v){.listingtable type=verilog numbers=true}

# あとがき {.unnumbered}