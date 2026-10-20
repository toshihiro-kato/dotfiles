function herdr-dev --description 'Open a herdr tab with claude in a 2x2 grid (port of zellij layouts/dev.kdl)'
    set -l label dev
    test (count $argv) -gt 0; and set label $argv[1]

    # キーバインド (type = "shell") 経由でも正しい cwd になるよう、フォーカス中ペインから取る
    set -l cwd (herdr pane current | jq -r '.result.pane.foreground_cwd')
    set -l top_left (herdr tab create --focus --label $label --cwd $cwd | jq -r '.result.root_pane.pane_id')
    or return 1
    set -l top_right (herdr pane split $top_left --direction right --ratio 0.5 | jq -r '.result.pane.pane_id')
    set -l bottom_left (herdr pane split $top_left --direction down --ratio 0.5 | jq -r '.result.pane.pane_id')
    set -l bottom_right (herdr pane split $top_right --direction down --ratio 0.5 | jq -r '.result.pane.pane_id')

    for pane in $top_left $top_right $bottom_left $bottom_right
        herdr pane run $pane claude >/dev/null
    end
end
