// ============================================
// Plate 3: 십자 보강재 - 수평 좌측 반쪽
// 크기: ~146 x 15 mm (OK)
// ============================================
use <../src/model_a_cross_brace.scad>

lcd_w = 350.66;
frame_wall = 6;
frame_outer_w = lcd_w + frame_wall * 2;

intersection() {
    model_a_cross_brace();
    translate([-frame_outer_w, -50, -1])
        cube([frame_outer_w, 100, 20]);
}
