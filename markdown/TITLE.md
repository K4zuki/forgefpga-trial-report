# まえがき {-}

## このドキュメントは何 {-}

この本は、~~ルネサス~~ダイアログセミコンダクターの小規模FPGA「ForgeFPGA」**SLG47910**の評価キットを購入し、簡単なプロジェクトを作ってデバッグするまでをまとめたドキュメントです。
2021年に魅力的な内容をプレスリリース[^1]したあと3年にわたって続報がなく、「_幻FPGA_」とか
「_ForgetFPGA_」など散々揶揄されてきた[^2][^3] ForgeFPGAですが、
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

\toc

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
