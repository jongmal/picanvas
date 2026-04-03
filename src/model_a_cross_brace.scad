// ============================================
// PiCanvas - 모델 A: 십자 보강재
// ============================================

// --- 공통 파라미터 (center_bracket과 동일) ---
bracket_size = 70;
bracket_thickness = 5;

// LCD 디스플레이
lcd_w = 350.66;
lcd_h = 216.25;
lcd_d = 3.2;

// 프레임
frame_bezel = 3;
frame_wall = 6;
frame_inner_w = lcd_w;
frame_inner_h = lcd_h;
frame_outer_w = lcd_w + frame_wall * 2;
frame_outer_h = lcd_h + frame_wall * 2;

// 십자 보강재
cross_bar_width = 15;
cross_bar_thickness = bracket_thickness;

// 도브테일 파라미터
dt_width = 15;
dt_depth = 5;       // 프레임 벽 두께 6mm 이내
dt_taper = 1;

// --- 모듈 ---

// 도브테일 암 (center_bracket 쪽 연결)
module dovetail_female(height) {
    clearance = 0.2;
    linear_extrude(height = height)
        polygon([
            [-(dt_width/2 - dt_taper) - clearance, 0],
            [(dt_width/2 - dt_taper) + clearance, 0],
            [dt_width/2 + clearance, dt_depth + clearance],
            [-dt_width/2 - clearance, dt_depth + clearance]
        ]);
}

// 프레임 벽에 삽입되는 도브테일 수 (끝단)
module dovetail_male_end() {
    linear_extrude(height = cross_bar_thickness)
        polygon([
            [-dt_width/2 + dt_taper, 0],
            [dt_width/2 - dt_taper, 0],
            [dt_width/2, dt_depth],
            [-dt_width/2, dt_depth]
        ]);
}

// 수평 바 (좌우, X축 방향)
module horizontal_bar() {
    // 바 길이: 중앙 브라켓 가장자리 → 프레임 내벽 (LCD 가장자리)
    bar_length_half = lcd_w / 2 - bracket_size / 2;

    module half_bar() {
        difference() {
            translate([0, -cross_bar_width/2, 0])
                cube([bar_length_half, cross_bar_width, cross_bar_thickness]);

            // 중앙 브라켓 도브테일 암 (빼기)
            translate([0, 0, 0])
                rotate([0, 0, -90])
                    translate([-dt_width/2 - 0.1, -dt_depth - 0.1, -0.5])
                        cube([dt_width + 0.2, dt_depth + 0.2, cross_bar_thickness + 1]);
        }

        // 프레임 벽 삽입용 도브테일 (끝단 → 벽 안쪽으로 돌출)
        translate([bar_length_half, 0, 0])
            dovetail_male_end();
    }

    // 오른쪽
    half_bar();

    // 왼쪽 (미러)
    mirror([1, 0, 0])
        half_bar();
}

// 수직 바 (상하, Y축 방향)
module vertical_bar() {
    bar_length_half = lcd_h / 2 - bracket_size / 2;

    module half_bar() {
        difference() {
            translate([-cross_bar_width/2, 0, 0])
                cube([cross_bar_width, bar_length_half, cross_bar_thickness]);

            // 중앙 브라켓 도브테일 암 (빼기)
            translate([0, 0, 0])
                rotate([0, 0, 0])
                    translate([-dt_width/2 - 0.1, -dt_depth - 0.1, -0.5])
                        cube([dt_width + 0.2, dt_depth + 0.2, cross_bar_thickness + 1]);
        }

        // 프레임 벽 삽입용 도브테일 (끝단)
        translate([0, bar_length_half, 0])
            rotate([0, 0, 90])
                dovetail_male_end();
    }

    // 위쪽
    half_bar();

    // 아래쪽 (미러)
    mirror([0, 1, 0])
        half_bar();
}

// --- 메인 ---

module model_a_cross_brace() {
    color("CadetBlue") {
        horizontal_bar();
        vertical_bar();
    }
}

// 단독 실행 시 프리뷰 → assembly.scad 사용 권장
