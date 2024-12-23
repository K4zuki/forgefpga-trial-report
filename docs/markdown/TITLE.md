# まえがき {-}

## このドキュメントは何 {-}

この本は、**『SLG47910V「ForgeFPGA」試してみたレポート』** の続編として、
秋月電子で売っている8x8マトリクスLEDを光らせるプロジェクトを解説したドキュメントです。

マトリクスLEDは「Pmod LEDマトリクス モジュール」[^1]を入手・組み立て、FPGA評価ボードに接続しました[^2]。
FPGA評価ボードがPMOD規格に正しく則った設計になっていることで、2連コネクタを含むすべての市販のPMODモジュールが使えます。

2024年11月ごろにデータシートの更新があり、VDDIOの範囲が3.3Vに拡張されています。開発環境を最新版にアップデートすると、実機デバッグの動作電圧が
3.5Vまで拡張されます。

## おことわり {-}

筆者はMac版とWindows版両方の環境を使っていますが、Windows版のみについて解説します。スクリーンショットはMac版が混じるかもしれません。

[^1]: <https://fugafuga.booth.pm/items/5219427>

[^2]: あいにく現在は売り切れているようですが、必ずしもこのボードを入手する必要はなく、ユニバーサル基板で自作すれば再現実験は可能です。

## 参考リンク集 {.unnumbered #reference-links}

- [[マトリクスLED PMOD基板解説ページ]{#pmodboard-readme}](https://github.com/ciniml/TangFPGAExtensions/blob/main/README_Pmod_MatrixLED.md)
- [[マトリクスLED PMOD基板購入ページ]{#pmodboard-purchase}](https://fugafuga.booth.pm/items/5219427)
- [[マトリクスLEDモジュール OSL641501-ARA]{#matrixled-akizuki}](https://akizukidenshi.com/catalog/g/g105163/)

- [[SLG47910V 製品ページ]{#slg47910-product-page}](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg47910-1k-lut-forgefpga)
- [[SLG47910V データシート]{#slg47910-datasheet-download}](https://www.renesas.com/us/en/document/dst/slg47910-datasheet?r=25546631)
- [[ForgeFPGAコンフィグレーションガイド]{#forgefpga-configuration-guide-download}](https://www.renesas.com/us/en/document/mah/forgefpga-configuration-guide?r=25546631)

- [[SLG7EVBFORGE（評価ボード） 製品ページ]{#evalboard-product-page}](https://www.renesas.com/us/en/products/programmable-mixed-signal-asic-ip-products/forgefpga-low-density-fpgas/slg7evbforge-1k-lut-forgefpga-evaluation-board)
- [[SLG7EVBFORGE（評価ボード） マニュアル]{#evalboard-manual}](https://www.renesas.com/us/en/document/mah/forgefpga-evaluation-board-r20-users-manual?r=25546646)

- [[SLG7EVBFORGE（評価ボード） Mouser販売ページ]{#evalboard-mouser}](https://www.mouser.jp/ProductDetail/Renesas-Dialog/SLG7EVBFORGE?qs=2wMNvWM5ZX5HC1b2oIQaEg%3D%3D)
- [[SLG7EVBFORGE（評価ボード） DigiKey販売ページ]{#evalboard-digikey}](https://www.digikey.jp/en/products/detail/SLG7EVBFORGE/1695-SLG7EVBFORGE-ND/22972057)

- [[SLG47910V IC DigiKey販売ページ]{#purchase-chip-digikey}](https://www.digikey.jp/en/products/detail/renesas-electronics-operations-services-limited/SLG47910V/25811413)
- [[SLG47910V IC Mouser販売ページ]{#purchase-chip-mouser}](https://www.mouser.jp/ProductDetail/724-SLG47910V#)

- [[開発環境ダウンロードページ]{#ide-download-page}](https://www.renesas.com/us/en/software-tool/go-configure-software-hub)
- [[開発環境マニュアル]{#ide-manual-download}](https://www.renesas.com/us/en/document/mat/go-configure-software-hub-user-guide)
- [[開発環境 Windows版]{#ide-windows-download}](https://www.renesas.com/us/en/document/sws/go-configure-software-hub-windows-64-bit)

\toc

# SLG47910Vについて若干のアップデート(C104比)

ICのデータシートが2024年11月に更新されました。また、MouserとDigikeyにIC商品ページが用意されました。

![参照したデータシートのリビジョン](images/slg47910v-datasheet-revision.png){#fig:datasheet-updated width=120mm}

## IO電圧範囲が3.3Vに拡大

VDDIOの範囲が拡張され、3.3V系でも動作するようになりました。

![推奨動作条件・改](images/slg47910v-recommended-operation-range.png){width=120mm #fig:operation-range}

![対応IOレベル・改](images/slg47910v-supported-io-levels.png){width=120mm #fig:io-levels}

## 本家サイトのディストリビューターリストが更新

[ルネサスの製品ページ](#slg47910-product-page)の最下部からディストリビュータ（代理店）一覧を呼び出せますが、その内容が少し変わりました。

### DigiKeyで買える（買えない）・Avnetで買えない

DigikeyとFutureの商品ページがリンクに追加されました。一方でAvnetへのリンクがなくなりました。

![Digikeyがディストリビュータに追加・Avnetが消失・Futureはリンク切れ・Mouserはあるけどない？](images/buy-from-avnet.png){#fig:distributors width=120mm}

あいにくDigikeyも5Kリールのみ・バックオーダー待ちです。Futureはリンクが切れています。

### Mouser君さぁ...

じつはMouserにも商品ページがあります。詐欺まがいなことに、1個から買えるように見えて、こちらも5Kフルリールしか受け付けていないそうです。

![Mouser商品ページ](images/buy-from-mouser.png){width=120mm #fig:buy-from-mouser}

# マトリクスLEDと基板の仕様

## LED

## 基板

# FPGAとLEDの接続

通常の開発では、IO planタブの表にFPGA回路[^Verilogで書く部分]とIC内の周辺回路[^内蔵オシレータ、PLL，IOピンなど、Verilogで取り扱えない部分]
の接続情報を打ち込んでいくのですが、実はこの表をCSVファイルでやり取りする方法があります。

[io plan.csv](../matrixled64/ffpga/src/io_plan.csv){.table delimiter=";" #tbl:io-plan-csv}

---

::: {.table}

| IC Pin | Peripheral          | Direction | FPGA core       |
|:------:|---------------------|:---------:|-----------------|
|   NA   | `OSC_EN`            |   <==<    | `osc_en`        |
|   NA   | `OSC_CLK`           |   >==>    | `i_clk`         |
|   NA   | `REF_LOGIC_AS_CLK0` |   <==<    | `scan_clk_out`  |
|   NA   | `LOGIC_AS_CLK0_EN`  |   <==<    | `scan_clk_oe`   |
|   NA   | `LOGIC_AS_CLK0`     |   >==>    | `i_lac0`        |
|   11   | `nRST`              |   >==>    | `i_nreset`      |
|   13   | `GPIO0_OUT`         |   <==<    | `o_row[1]`      |
|   13   | `GPIO0_OE`          |   <==<    | `o_row_oe[1]`   |
|   14   | `GPIO1_OUT`         |   <==<    | `o_row[3]`      |
|   14   | `GPIO1_OE`          |   <==<    | `o_row_oe[3]`   |
|   15   | `GPIO2_OUT`         |   <==<    | `o_row[5]`      |
|   15   | `GPIO2_OE`          |   <==<    | `o_row_oe[5]`   |
|   16   | `GPIO3_OUT`         |   <==<    | `o_row[7]`      |
|   16   | `GPIO3_OE`          |   <==<    | `o_row_oe[7]`   |
|   17   | `GPIO4_OUT`         |   <==<    | `o_row[0]`      |
|   17   | `GPIO4_OE`          |   <==<    | `o_row_oe[0]`   |
|   18   | `GPIO5_OUT`         |   <==<    | `o_row[2]`      |
|   18   | `GPIO5_OE`          |   <==<    | `o_row_oe[2]`   |
|   19   | `GPIO6_OUT`         |   <==<    | `o_row[4]`      |
|   19   | `GPIO6_OE`          |   <==<    | `o_row_oe[4]`   |
|   20   | `GPIO7_OUT`         |   <==<    | `o_row[6]`      |
|   20   | `GPIO7_OE`          |   <==<    | `o_row_oe[6]`   |
|   23   | `GPIO8_OUT`         |   <==<    | `o_col[6]`      |
|   23   | `GPIO8_OE`          |   <==<    | `o_col_oe[6]`   |
|   24   | `GPIO9_OUT`         |   <==<    | `o_col[4]`      |
|   24   | `GPIO9_OE`          |   <==<    | `o_col_oe[4]`   |
|   1    | `GPIO10_OUT`        |   <==<    | `o_col[2]`      |
|   1    | `GPIO10_OE`         |   <==<    | `o_col_oe[2]`   |
|   2    | `GPIO11_OUT`        |   <==<    | `o_col[0]`      |
|   2    | `GPIO11_OE`         |   <==<    | `o_col_oe[0]`   |
|   3    | `GPIO12_OUT`        |   <==<    | `o_col[7]`      |
|   3    | `GPIO12_OE`         |   <==<    | `o_col_oe[7]`   |
|   4    | `GPIO13_OUT`        |   <==<    | `o_col[5]`      |
|   4    | `GPIO13_OE`         |   <==<    | `o_col_oe[5]`   |
|   5    | `GPIO14_OUT`        |   <==<    | `o_col[3]`      |
|   5    | `GPIO14_OE`         |   <==<    | `o_col_oe[3]`   |
|   6    | `GPIO15_OUT`        |   <==<    | `o_col[1]`      |
|   6    | `GPIO15_OE`         |   <==<    | `o_col_oe[1]`   |
|   7    | `GPIO16_OUT`        |   <==<    | `testbus[0]`    |
|   7    | `GPIO16_OE`         |   <==<    | `testbus_oe[0]` |
|   8    | `GPIO17_OUT`        |   <==<    | `testbus[1]`    |
|   8    | `GPIO17_OE`         |   <==<    | `testbus_oe[1]` |
|   9    | `GPIO18_OUT`        |   <==<    | `testbus[2]`    |
|   9    | `GPIO18_OE`         |   <==<    | `testbus_oe[2]` |

:::

# 固定パターンを出すだけのサンプル

## Verilogコード

### トップモジュール`top.v`

[top.v](../matrixled64/ffpga/src/main.v){.listingtable type=verilog #lst:main-module-list}

### クロック分周モジュール`clk_divider.v`

[clk_divider.v](../matrixled64/ffpga/src/clk_divider.v){.listingtable type=verilog #lst:clk_divider-module-list}

# あとがき

- フィルタ挙動の問題が解決していないため、今回もPandocは2.19版を使いました。

- ![](images/QRcode.png){width=80mm} &larr;原稿はこちらから
