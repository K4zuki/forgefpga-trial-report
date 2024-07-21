# まえがき {-}

## このドキュメントは何 {-}

この本は、~~ルネサス~~ダイアログセミコンダクターの小規模FPGA「ForgeFPGA」**SLG47910**の評価キットを購入し、簡単なプロジェクトを作ってデバッグするまでをまとめたドキュメントです。
2021年に魅力的な内容をプレスリリース[^1]したあと3年にわたって続報がなく、「_幻FPGA_」とか
「_Forge**T**FPGA_」など散々揶揄されてきた[^2][^3] ForgeFPGAですが、
2024年6月、突然Mouser/Digikey/直販サイトで評価キットが入手可能になりました。筆者も、ちょうど夏コミに間に合う時期ということで、小さい方のキットを
Mouserで購入して試すことにしました。あいにくICはまだ入手できず、キットに付属するサンプルも10個しかないので、自作基板は作りません。

データシート[^4]によると、CPUなどからビットストリームを直接流し込んだり、SPIフラッシュROMからロードさせることができるようなので、一通り調査してみたいと思います。

[^1]: <https://www.renesas.com/jp/ja/about/press-room/renesas-enters-fpga-market-first-ultra-low-power-low-cost-family-addressing-low-density-high-volume>

[^2]: <https://community.renesas.com/analog-products/f/greenpak-greenfet/28390/forgefpga-datasheets/108088#108088>

[^3]: <https://community.renesas.com/analog-products/f/greenpak-greenfet/29049/forgefpga-availability/109444#109444>

[^4]: <https://www.renesas.com/us/en/document/dst/slg47910-datasheet?r=25546631>

## 参考リンク集 {-}

- [SLG47910V 製品ページ](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg47910-1k-lut-forgefpga?partno=SLG47910V)
- [SLG47910V データシート](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg47910-1k-lut-forgefpga>)
- [ForgeFPGAコンフィグレーションガイド](https://www.renesas.com/us/en/document/mah/forgefpga-configuration-guide?r=25546631)

- [SLG7EVBFORGE（評価ボード） 製品ページ](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg7evbforge-1k-lut-forgefpga-evaluation-board)
- [SLG7EVBFORGE（評価ボード） マニュアル](https://www.renesas.com/us/en/document/mah/forgefpga-evaluation-board-r20-users-manual?r=25546646)

- [SLG7EVBFORGE（評価ボード） Mouser販売ページ](https://www.mouser.jp/ProductDetail/Renesas-Dialog/SLG7EVBFORGE?qs=2wMNvWM5ZX5HC1b2oIQaEg%3D%3D)
- [SLG7EVBFORGE（評価ボード） DigiKey販売ページ](https://www.digikey.jp/en/products/detail/SLG7EVBFORGE/1695-SLG7EVBFORGE-ND/22972057)

- [開発環境ダウンロードページ](https://www.renesas.com/us/en/software-tool/go-configure-software-hub)
- [開発環境マニュアル](https://www.renesas.com/us/en/document/mat/go-configure-software-hub-user-guide)
- [開発環境 Windows版](https://www.renesas.com/us/en/document/sws/go-configure-software-hub-windows-64-bit)

\toc

# ForgeFPGA SLG47910 の主な仕様

以下に主な仕様一覧を示します。0.5mmピッチ24ピンQFN、この内最大19ピンをIOに使えます。電源はIOとコアで**2系統**必要です。
また、IOレベルは低めの**2.5Vまたは1.8V系**で動作します。Arduinoやラズパイを直結するとたぶん壊れます。
ビットストリーム（内部結線情報）のSPIフラッシュからのロード、SPIホストからの書き込み、内蔵ワンタイムROMからのロードができます。

::: {.table noheader=true}

|    パッケージ    | 0.5mmピッチ24ピンQFN（EPなし）                  |
|:-----------:|----------------------------------------|
| 動作電圧（VDDIO） | 1.71 - **2.75**V (LVCMOS18 / LVCMOS25) |
| 動作電圧（VDDC）  | 1.1V &plusmn; 10%                      |
|  ５ビットLUT数   | 1120                                   |
|    DFF数     | 1120                                   |
|   動作温度範囲    | -40 - 85 &deg;C                        |
|  内蔵クロック周波数  | 50MHz                                  |
|   最大GPIO数   | 19                                     |

Table: SLG47910 Spec {#tbl:slg47910-spec}
:::

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

# 評価ボード

## 購入（Mouserの場合）

::: rmnote

> **このファイルは何**
>
> このファイルはPandockerがデフォルトで参照する原稿Markdownファイル`TITLE.md`のテンプレートです。
> **素のPandocでは実現できない機能の説明を含みます。**
>
> ------------------------
>
> **Pandoc的Divとrmnote**
>
> Pandocはコロン`:`3個ずつで囲まれた部分をDivとして扱います(fenced divs; <https://pandoc.org/MANUAL.html#divs-and-spans>)。
> 任意のclassやattributeを付与することができるので、
> フィルタのトリガやCSSで色設定をするなどの後処理に使えます。ちなみにこのDivはrmnoteクラスが付与されていて、
> `removalnote.lua`というLuaフィルタの処理対象です。メタデータの設定によって、すべてのrmnoteクラスDivの出力を
> 抑圧することができます。`config.yaml`を編集してください。
>
> **GitHubその他普通のレンダラでは三連コロンを解釈してくれないので、**
> **きれいなレンダリングを保つために前後に改行を入れておくことをおすすめします。**
>
> ---

> **TOC(目次)挿入**
>
> `\toc`を任意の場所に書いておくと、Luaフィルタ`docx-pagebreak-toc.lua`がその場所に目次を生成します。
> 現在のところ、Docx出力のみが対象です。目次の前は必ず改ページします。目次のあとは改ページしません。
> `toc-title`メタデータによって目次の見出しを変更できます。`config.yaml`を編集してください。

[](markdown/config.yaml){.listingtable from=18 to=20}

&darr;

:::

::: rmnote

> **Pagebreak(改ページ)挿入**
>
> `\newpage`を任意の場所に書いておくと、Luaフィルタ`docx-pagebreak-toc.lua`が処理して改ページします。
> Docx出力とLaTeX出力が対象です。PDF出力のときも動きますが、`--pdf-engine`の設定によってはうまく動かないかもしれません。

&darr;

:::

\newpage

::: rmnote

> **番号なし見出し**
>
> レベル1~5の`.unnumbered`クラスが付与された見出しから番号付けを外します。Docx出力が対象です。
> 予め番号なし見出しスタイルを用意する必要があります。見出しスタイルの設定によって、
> 見出しの前で改ページするかどうかの挙動が変わります。

&darr;

:::

# 番号なし見出し1 {.unnumbered}

## 番号なし見出し2 {.unnumbered}

### 番号なし見出し3 {.unnumbered}

::: rmnote

> **下線**
>
> 任意のSpanに`underline`クラスを付与すると下線がつきます。Docx出力に加えLaTeX出力(*)が対象です。
>
> (*): LaTeX出力では`tex-underline.lua`が処理します。
>
> 例：`**下線**`
>
> ![QR](images/QRcode.png){#fig:qr-code width=120mm}

:::
