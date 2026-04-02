// ============================================
// PiCanvas - 전체 어셈블리
// ============================================

use <model_a_center_bracket.scad>
use <model_a_cross_brace.scad>
use <model_a_frame.scad>
use <model_b_wall_bracket.scad>

// --- 파라미터 ---
wall_plate_thickness = 5;
tb_thickness = 10.5;
bracket_thickness = 5;
frame_lip_depth = 2;
lcd_d = 3.2;

// Z 오프셋 계산
z_model_b = 0;
z_turntable = wall_plate_thickness;
z_model_a_bracket = wall_plate_thickness + tb_thickness;
z_cross_brace = z_model_a_bracket;
z_frame = z_model_a_bracket;

// --- 어셈블리 ---

// Model B (벽면 브라켓)
translate([0, 0, z_model_b])
    model_b_wall_bracket();

// 턴테이블 베어링 (디버그 표시)
%translate([-57/2, -57/2, z_turntable])
    color("Gray", 0.5)
        cube([57, 57, tb_thickness]);

// Model A - 중앙 브라켓 + 풀리
translate([0, 0, z_model_a_bracket])
    model_a_center_bracket();

// Model A - 십자 보강재
translate([0, 0, z_cross_brace])
    model_a_cross_brace();

// Model A - 프레임
translate([0, 0, z_frame])
    model_a_frame_assembly();

// Raspberry Pi 4B (디버그 표시)
%translate([-85/2, 30, z_model_a_bracket + bracket_thickness])
    color("Green", 0.5)
        cube([85, 56, 17]);

// eDP 컨트롤러 보드 (디버그 표시)
%translate([50, -60, z_model_a_bracket + bracket_thickness])
    color("Purple", 0.5)
        cube([44.5, 31.5, 5]);

// LCD 패널 (디버그 표시)
%translate([-350.66/2, -216.25/2, z_frame + frame_lip_depth])
    color("Red", 0.3)
        cube([350.66, 216.25, lcd_d]);
