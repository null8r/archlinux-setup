# 細かいセットアップ（実行しなくても良い）
[Hyprlandのインストール](01_install.md)が完了した後に行う細かいセットアップ。

# 日本語環境
`fcitx5`の自動起動。
```bash
vim ~/.config/hypr/hyprland.conf
```
ここに以下を追加。
```
exec-once = fcitx5 -d
```

日本語キーボードの設定。
```bash
~/.config/hypr/hyprland/general.conf
```
`input`セクションを編集。
```
input {
    kb_layout = jp
    numlock_by_default = false #NumLockをデフォルトでオフにする
}
```

# バーの日時を編集
`yyyy/MM/dd (ddd)`の形式に変更する。
```bash
~/.config/quickshell/ii/modules/ii/bar
```
以下のように編集する。

`ClockWidget.qml`
```diff
Item {
    ...省略...
    RowLayout {
        ...
        StyledText {
            ...
        }

        StyledText {
            ...
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
+           text: Qt.locale("ja_JP").toString(DateTime.clock.date, "MM/dd(ddd)")
        }
```

`ClockWidgetPopup.qml`
```diff
StyledPopup {
    id: root
+   property string formattedDate: Qt.locale("ja_JP").toString(DateTime.clock.date, "yyyy/MM/dd (ddd)")
    property string formattedTime: DateTime.time
    property string formattedUptime: DateTime.uptime
    property string todosSection: getUpcomingTodos()

    ...省略...
}
```

# Night Lightの無効化
勝手に起動されてウザいので無効化する。
```bash
~/.config/quickshell/ii/services/Hyprsunset.qml
```
これを[Hyprsunset.qml](src/Hyprsunset.qml)のように編集する。

# VPNインジケーターの設置
ProtnVPNのインジケーターを設置する。
```bash
~/.config/quickshell/ii/modules/ii/bar
```
ここに[VpnIndicator.qml](src/VpnIndicator.qml)を作る。

`BarContent.qml`の下の方に追記する。
```diff
+ // VPN
+ Loader {
+     Layout.leftMargin: 4
+     active: true
+     sourceComponent: BarGroup {
+         VpnIndicator {}
+     }
+ }

// Weather
Loader {
    ...省略...
}
```

# PowerProfileを使いたい場合
```bash
yay -S power-profiles-daemon
```

# 音が出ない場合
```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```