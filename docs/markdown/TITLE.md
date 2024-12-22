# まえがき {-}

## このドキュメントは何 {-}

この本は、**『SLG47910V「ForgeFPGA」試してみたレポート』** の続編として、
忘れられたFPGA「ForgeFPGA」**SLG47910**を使い、8x8マトリクスLEDを光らせるプロジェクトを解説したドキュメントです。

マトリクスLEDは「Pmod LEDマトリクス モジュール」[^1]を入手し、FPGA評価ボードに直結しました[^2][^3]。

2024年11月ごろにデータシートの更新があり、VDDIOの範囲が3.3Vに拡張されています。開発環境を最新版にアップデートすると3.3V動作が可能になります。

## おことわり {-}

筆者はMac版とWindows版両方の環境を使っていますが、Windows版のみについて解説します。スクリーンショットはMac版が混じるかもしれません。

[^1]: <https://fugafuga.booth.pm/items/5219427>

[^2]: FPGA評価ボード、ちゃんとPMOD規格に沿った設計がなされていてえらい(&reg;のマイコン評価ボードのナンチャッテPMODとは違うのだよ)

[^3]: あいにく現在は売り切れているようですが、必ずしもこのボードを入手する必要はなく、ユニバーサル基板で自作すれば再現実験は可能です。

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

- [[開発環境ダウンロードページ]{#ide-download-page}](https://www.renesas.com/us/en/software-tool/go-configure-software-hub)
- [[開発環境マニュアル]{#ide-manual-download}](https://www.renesas.com/us/en/document/mat/go-configure-software-hub-user-guide)
- [[開発環境 Windows版]{#ide-windows-download}](https://www.renesas.com/us/en/document/sws/go-configure-software-hub-windows-64-bit)

\toc

# SLG47910Vについて若干のアップデート

## IO電圧範囲が3.3Vに拡大

## DigikeyやMouserで買える（買えない）

### Mouser君さぁ...

# マトリクスLEDと基板の仕様

## LED

## 基板

# FPGAとLEDの接続

# 固定パターンを出すだけのサンプル

### トップモジュール`top.v`

### クロック分周モジュール`clk_divider.v`

# あとがき

- Pandoc2.19と3.2の間でグラフィック周りの扱いが変わって、自作Luaフィルタの挙動がおかしくなってしまった。
  なので、今回も2.19版を使いました。

- ![](images/QRcode.png){width=80mm} &larr;原稿はこちらから
