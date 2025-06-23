# kappa3-sdk

[電気情報工学科C課程（CM）第3学年ハードウェア実験](https://github.com/kappa3-rv32i/hw2019)
の課題をVerilogシミュレータを使って実施するための環境。

授業資料のテストを自動化している。

## Requirements
動作確認環境：Ubuntu 22.04.5 LTS on WSL2
```sh
sudo apt install iverilog
sudo apt install gtkwave 
```

## Test
1. `./kappa3-light/src`配下に必要なファイルをコピーする。
  このとき、`mem64kd.v`は、このリポジトリのものを使う。
1. 授業資料では`debugger`モジュールの`mem_read`, `mem_write`が32bitで宣言されているが、これは誤りなので1bitに修正する。
1. テストの実行
    ```sh
    cd kappa3-light
    ./run.sh
    ```
1. テストに失敗した場合、gtkwaveを使ってすべての配線の状態を確認することができる。
    ```sh
    gtkwave test.vcd
    ```