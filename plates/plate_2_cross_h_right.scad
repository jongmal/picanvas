// ============================================
// Plate 2: 십자 보강재 - 수평 우측 반쪽
// 크기: ~146 x 15 mm (OK)
// ============================================
use <../src/model_a_cross_brace.scad>

// 수평바 우측 반쪽만 추출
lcd_w = 350.66;
frame_wall = 6;
frame_outer_w = lcd_w + frame_wall * 2;
bracket_size = 70;
bar_len = frame_outer_w / 2 - bracket_size / 2;

intersection() {
    model_a_cross_brace();
    translate([0, -50, -1])
        cube([frame_outer_w, 100, 20]);
}
