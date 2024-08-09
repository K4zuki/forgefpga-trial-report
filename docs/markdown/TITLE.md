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

[@tbl:slg47910-spec]に主な仕様一覧を示します。0.4mmピッチ24ピンSTQFN(3ミリ角)、この内最大19ピンをIOに使えます。電源はIOとコアで**2系統**必要です。
また、IOレベルは低めの**2.5Vまたは1.8V系**で動作します。Arduinoやラズパイを直結するとたぶん壊れます。
ビットストリーム（内部結線情報）のSPIフラッシュからのロード、SPIホストからの書き込み、内蔵ワンタイムROMからのロードができます。SPIは専用ではなく、GPIOと共有です。当然ですがフラッシュも1.8V動作品が必要です。
筆者は秋月で売っているもの^[<https://akizukidenshi.com/catalog/g/g118046/>]を入手済ですが、ROMライターの類を持っていないので、まだ実験には至っていません。

以降の各節にデータシート抜粋写真を置いておきます。パッケージ外観どアップ写真（[@fig:package-closeup]）はiPhoneのマクロ機能で撮ったあと加工しているのでガビってます。

::: {.table noheader=true}

|    パッケージ    | 0.4mmピッチ24ピンSTQFN（EPなし）                |
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

![内部ブロック図(データシート抜粋)](images/block_diagram.png){#fig:internal-diagram width=110mm}

## パッケージとピン配置

0.4ミリピッチ24ピン、STQFN（Small Thin QFN？）パッケージ、３ミリ角。外形が小さすぎるせいか、
放熱・グランド用のパッドはありません。24ピンのうちGPIOは最大19本（`GPIO0`～`GPIO18`）、
そのうちSPIメモリまたはホストからのロードに兼用されているものが4本あります。

残りはコア電源とIO電源に各1ピンずつ、メモリ保持とリセットに1ピンずつ、グラウンドで1ピンです。

寸法図を見ると、パッドの大きさが均一ではないのでPCBライブラリ作成には注意が必要です。

![ピン配置図（データシート抜粋）](images/slg47910v-pinout-descriptions.png){#fig:pinout-description width=150mm}

![パッケージ図面（データシート抜粋）^[ボトムビューの1番ピンの位置がトップビューとあってなくて気持ち悪いなっておもいます]](images/slg47910v-package-dimension.png){#fig:package-dimension width=150mm}

![パッケージ外観（トップビュー）](images/slg47910v-package-closeup.png){#fig:package-closeup height=90mm}

![パッケージ外観（ボトムビュー）](images/slg47910v-package-closeup-bottom.png){#fig:package-closeup-bottom height=90mm}

## 電圧仕様

![推奨動作条件（データシート抜粋）](images/slg47910v-recommended-operation-range.png){#fig:recommended-operation-range width=150mm}

![IO電圧（データシート抜粋）](images/slg47910v-supported-io-levels.png){#fig:supported-iko-levels width=150mm}

## リセットとメモリ保持

![ピン配置図（データシート抜粋）](images/slg47910v-reset-retention-table.png){#fig:reset-retention-truth-table width=150mm}

## GPIO機能一覧（SPIロード兼用ピンを除く）

![GPIO機能一覧（SPIロード兼用ピンを除く）（データシート抜粋）](images/slg47910v-gpio-nonspi-functions.png){#fig:gpio-nonspi-functions width=150mm}

## GPIO機能一覧（SPIロード兼用ピン）

![GPIO機能一覧（SPIロード兼用ピン）（データシート抜粋）](images/slg47910v-gpio-spi-functions.png){#fig:gpio-spi-functions width=150mm}

SPI兼用ピンはGPIO3～6の4本です。`SPI_SS`と`PWR`/`EN`の設定によって、外部SPIメモリからロードするマスタモードと、外部マイコン
などが書き込むスレーブモードがあります。MISO・MOSIの割り当てピンが変わるので注意が必要です。

モード設定とロードの手順は[ForgeFPGAコンフィグレーションガイド](#forgefpga-configuration-guide-download)を参照してください。

# 設計ソフト

まず設計ソフトを入手します。GreenPAKと共通なので、すでに持っている方は最新版にアップデートするのが最短です。

従来のGreenPAKソフトのインターフェースと、ソースコード・テストベンチ編集、RTL・ビットストリーム生成、シミュレーションを行えるIDE
の2ウィンドウで構成されます。

GPAKインターフェースはIDEの起動、IOピンのドライブ能力やプルアップ・プルダウンの設定、ライタとの接続・実機デバッグ・書き込みを行います。

## ダウンロード（Windows版）

参考リンク集から[ダウンロードページ](#ide-download-page)に行き、[Windows版](#ide-windows-download)を入手します。
ダイアログの頃とは異なり、ダウンロードには[ユーザ登録とログインが必要]{.underline}です。また、過去バージョンへのアクセスもなさそうです。
そういうとこやぞ&reg;

![設計ソフトダウンロードページ](images/software_download_page.png){#fig:software-download-page width=150mm}

## GreenPAKデザイナーインターフェース

![IDEメインウィンドウ](images/software-gpak-window.png){#fig:software-gpak-window width=150mm}

![IOピンコンフィグ](images/software-pin-config.png){#fig:software-pin-config width=100mm}

![IDEデバッガ選択](images/software-debugger-select.png){#fig:software-debugger-select width=150mm}

## IDEウィンドウ

![software-ide-window.png](images/software-ide-window.png){#fig:software-ide-window width=150mm}

### HDLのコンパイル（Synthesis）

HDLのコンパイルには*iverilog*を使っているようです。ルネのダウンロードページに何もリンクの類いがないので、
ソフトのインストールに伴って同時にインストールされると思います。

### シミュレーション

### ビットストリーム生成

::: rmnote

- ビットストリームのHEX出力ができない

:::

# 評価ボード

評価ボードを入手して実動作を見てみました。

![[評価ボード製品ページ](#evalboard-product-page)](images/eval_board_page.png){#fig:eval-board-page width=120mm}

## 購入（Mouserの場合）

筆者はMouserから評価ボードを購入しました。商品ページには[リンク集](#evalboard-mouser)から飛べます。

![SLG7EVBFORGE（評価ボード） Mouser販売ページ](images/evalboard-mouser-page.png){#fig:screenshot-mouser-page width=120mm}

ルネにしては梱包がかなりシンプルで、化粧箱のたぐいはなく、本体基板・USBA-Cケーブル・サンプルチップがそれぞれESD袋に入ってホチキスで止められてきました。

##### 配送業者はUPSを選択...何故か*名古屋*に飛ばされる

筆者は配送業者をUPSに指定（Mouserのデフォルト・関税無料）しました。その後順調に成田のUPS施設に来て、「地元の業者」ことヤマト運輸に委託されたのですが、
そこで何らかの手違いが起きたらしく、何故か名古屋に飛ばされました。サポートセンターに若干たらい回しされました（転送料払えとか言われた（なんでやねん））が、1日遅れで届きましたとさ。
東京と名古屋で住所がかぶる地域があったというのが原因だそうです。そうはならんやろ案件でした。

## 外観

[@fig:evalkit-overview.png]にボードの外観を示します。ピンヘッダや基板表面に色がついているのは筆者による加工です。
上の方にUSBコネクタ・電源・ライタ、中段にソケットとブレークアウトピンヘッダ、下の端にPMODコネクタが用意されています。

![評価ボード外観](evalkit-overview.png){#fig:evalkit-overview.png height=150mm}

### USBコネクタ・電源・ライタ

USB－CコネクタはどうやらUSB2.0タイプのようです。ここから電源を取って書き込み用マイコンと
IO・コア電源生成用オンボードレギュレータにつながっています。

![USBコネクタ・電源・ライタ](images/evalboard-usb-reg.png){#fig:evalboard-usb-reg width=120mm}

\newpage

### ソケット・ブレークアウトピンヘッダ

メイン部分と言ってよい、ソケットとヘッダが出ている部分です。ソケットの留め具は緩めなので注意してください。
筆者は貴重なサンプルを1個なくしました。写真を撮ろうとして触ってたら築かぬうちに開いてました。3ミリ角を探し出すのはむりぽです。

ブレークアウトピンヘッダは、ICのすべてのピンが直結されています。ソケットに近い列はグランドで、外側に信号が出ています。

![ソケット・ブレークアウトピンヘッダ](images/evalboard-socket.png){#fig:evalboard-socket width=120mm}

\newpage

### PMODコネクタ

Xilinx型FPGAボードによくついているPMODコネクタが用意されています。2段タイプを2組です。
ちゃんと規格に沿った配置になっているので、2ポートいるPMODボードも刺さります。

![PMODコネクタ](images/evalboard-pmod.png){#fig:evalboard-pmod width=120mm}

::: rmnote

\newpage

## ICの単体購入はできな...くはない（買えるとは言っていない）

SLG47910チップ単体の直販購入はまだできず、サンプル請求しかありません（将来的に直販が開放されるかどうかも不明）。
ルネのポリシーとしては、Gmailなどのメールアドレスで登録されたユーザからのサンプル請求を拒否するようです。そういうとこやぞ&reg;

ルネの製品ページからAVNETの商品ページに飛べますが、[フルリール5000個]{.underline}でしか購入できません。なお、執筆時点(2024年8月)では在庫がありません。

![ルネサス製品ページ（直販メニュー）](images/buy-from-avnet.png){#fig:buy-from-avnet width=130mm}

![AVNET商品ページ（在庫なし）](images/buy-from-avnet-2.png){#fig:buy-from-avnet-2 width=130mm}

\newpage

# VGAランダム出力プロジェクトを作ってみる

[main.v](../vga_random/ffpga/src/main.v){.listingtable type=verilog numbers=true}

:::

# あとがき {.unnumbered}

＃このあとがきは、今にも落ちそうなのをぎりぎり踏みとどまっている木曜日に書かれました。

![原稿はこちらから](images/QRcode.png){width=80mm}