// ============================================
// PiCanvas - 전체 어셈블리
// ============================================
// Z축: 전면(Z=0) → 벽면(Z=+)
// 보는 방향: Z- 쪽에서 바라봄 (전면이 위)
//
// 적층순서 (전면→벽):
// Z=0          : 프레임 전면 립 (베젤) ← 가장 앞
// Z=2          : LCD 패널 전면
// Z=5.2        : LCD 패널 후면
// Z=6.2        : 프레임 후면
// Z=6.2        : 십자 보강재 / 중앙 브라켓
// Z=6.2~11.2   : 브라켓(5mm)
// Z=11.2~19.2  : 풀리 링(8mm) ← 벽쪽으로 돌출
// Z=11.2~28.2  : Pi 4B (17mm) ← 벽쪽으로 매달림
// Z=19.2       : 턴테이블 회전판
// Z=19.2~29.7  : 턴테이블 베어링 (10.5mm)
// Z=29.7~34.7  : 모델 B (5mm)
// Z=34.7       : 벽면

use <model_a_center_bracket.scad>
use <model_a_cross_brace.scad>
use <model_a_frame.scad>
use <model_b_wall_bracket.scad>

// --- 파라미터 ---
frame_depth = 3.2 + 3;   // 6.2mm
frame_lip_depth = 2;
lcd_d = 3.2;
bracket_thickness = 5;
pulley_ring_height = 8;
tb_thickness = 10.5;
wall_plate_thickness = 5;

// --- Z 오프셋 (전면=0, 벽=+) ---
z_frame_front = 0;                                            // 0
z_frame_back = frame_depth;                                   // 6.2
z_bracket = z_frame_back;                                     // 6.2
z_bracket_back = z_bracket + bracket_thickness;               // 11.2
z_pulley_back = z_bracket_back + pulley_ring_height;          // 19.2
z_turntable = z_pulley_back;                                  // 19.2
z_turntable_back = z_turntable + tb_thickness;                // 29.7
z_model_b = z_turntable_back;                                 // 29.7
z_wall = z_model_b + wall_plate_thickness;                    // 34.7

// --- 어셈블리 ---

// 프레임 (Z=0이 전면 립, Z=6.2이 후면)
translate([0, 0, z_frame_front])
    model_a_frame_assembly();

// LCD 패널 (디버그)
%translate([-350.66/2, -216.25/2, frame_lip_depth])
    color("Red", 0.3)
        cube([350.66, 216.25, lcd_d]);

// 십자 보강재
translate([0, 0, z_bracket])
    model_a_cross_brace();

// 중앙 브라켓 + 풀리 (풀리가 +Z=벽쪽으로 돌출)
translate([0, 0, z_bracket])
    model_a_center_bracket();

// 턴테이블 베어링 (디버그)
%translate([-57/2, -57/2, z_turntable])
    color("Gray", 0.5)
        cube([57, 57, tb_thickness]);

// Model B (벽면 브라켓)
translate([0, 0, z_model_b])
    model_b_wall_bracket();

// --- 디버그: 부품 (프레임 후면~벽 사이 공간に配置) ---

// Raspberry Pi 4B (브라켓 뒤쪽에 매달림)
%translate([-85/2, 30, z_bracket_back])
    color("Green", 0.5)
        cube([85, 56, 17]);

// eDP 컨트롤러 보드
%translate([50, -60, z_bracket_back])
    color("Purple", 0.5)
        cube([44.5, 31.5, 5]);
