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

![Digikeyがディストリビュータに追加・Avnetが消失・Futureはリンク切れ](images/buy-from-avnet.png){#fig:distributors width=120mm}

あいにくDigikeyも5Kリールのみ・バックオーダー待ちです。Futureはリンクが切れています。

### Mouser君さぁ...

じつはMouserにも商品ページがあります。詐欺まがいなことに、1個から買えるように見えて、こちらも5Kフルリールしか受け付けていないそうです。

![Mouser商品ページ](images/buy-from-mouser.png){width=120mm #fig:buy-from-mouser}

# マトリクスLEDと基板の仕様

## LED

## 基板

# 固定パターンを出すだけのサンプルプロジェクト

斜めに半分だけ光らせるサンプルです。githubにプロジェクト一式置いておきます。

#### ブロック図 {-}

FPGA回路と周辺の接続ブロック図を示します。HDLで書く部分は緑色、IOピンは青、その他の周辺回路はオレンジ色の箱で示してあります。

![ブロック図](images/port-connections.png){width=120mm #fig:port-connection-diagram}

## IOプラン

### CSVでIOプランをやり取り

通常の開発では、IO planタブの表にFPGA回路^[Verilogで書く部分] とIC内の周辺回路^[内蔵オシレータ、PLL，IOピンなど、Verilogで取り扱えない部分]
の接続情報を打ち込んでいくのですが、実はこの表をCSVファイルでやり取りする方法があります。

[io plan.csv](../matrixled64/ffpga/src/io_plan.csv){.table delimiter=";" #tbl:io-plan-csv}

## Verilogコード

### トップモジュール`top.v`

[top.v](../matrixled64/ffpga/src/main.v){.listingtable type=verilog #lst:main-module-list}

\newpage

### クロック分周モジュール`clk_divider.v`

`i_clk`を`DIVISOR`分周したものを`o_clk`に出力します^[divisorは除数の意]。

[clk_divider.v](../matrixled64/ffpga/src/clk_divider.v){.listingtable type=verilog #lst:clk_divider-module-list}

# あとがき

- フィルタ挙動の問題が解決していないため、今回もPandocは2.19版を使いました。

- ![](images/QRcode.png){width=80mm} &larr;原稿はこちらから
