// ============================================
// Plate 5: 십자 보강재 - 수직 하단 반쪽
// 크기: 15 x ~79 mm (OK)
// ============================================
use <../src/model_a_cross_brace.scad>

lcd_h = 216.25;
frame_wall = 6;
frame_outer_h = lcd_h + frame_wall * 2;

intersection() {
    model_a_cross_brace();
    translate([-50, -frame_outer_h, -1])
        cube([100, frame_outer_h, 20]);
}
