// ============================================
// PiCanvas - 모델 A: 중앙 브라켓 + GT2 80T 풀리
// ============================================

// --- 파라미터 ---

// 턴테이블 베어링
tb_size = 57;           // 턴테이블 정사각형 한 변 (mm)
tb_thickness = 10.5;    // 턴테이블 두께
tb_bolt_inset = 5;      // 볼트홀 가장자리로부터 안쪽 거리 (가정)
tb_bolt_dia = 4.2;      // M4 관통홀 직경
tb_bolt_count = 4;

// GT2 80T 풀리 (외치)
gt2_pitch = 2;          // GT2 피치 (mm)
gt2_teeth = 80;         // 치수
gt2_pitch_dia = gt2_teeth * gt2_pitch / PI;  // ~50.93mm
gt2_outer_dia = gt2_pitch_dia + 1.0;         // 치 끝 직경 (약간의 여유)
gt2_root_dia = gt2_pitch_dia - 1.5;          // 치 뿌리 직경
gt2_belt_width = 6;     // 벨트 폭
gt2_tooth_depth = (gt2_outer_dia - gt2_root_dia) / 2;

// 중앙 브라켓
bracket_size = 70;      // 브라켓 정사각형 크기 (턴테이블보다 큼)
bracket_thickness = 5;  // 브라켓 두께
pulley_ring_height = gt2_belt_width + 2;  // 풀리 링 높이 (벨트폭 + 가이드)
pulley_ring_inner_dia = gt2_root_dia - 4; // 링 내경
pulley_guide_height = 1; // 벨트 이탈 방지 가이드 높이

// --- 모듈 ---

// GT2 외치 풀리 프로파일 (단면)
module gt2_tooth_profile() {
    // GT2 치형 근사: 반원형 골
    tooth_pitch = gt2_pitch;
    tooth_radius = 0.75;  // GT2 치형 반원 반지름

    difference() {
        circle(d = gt2_outer_dia, $fn = 360);

        // 각 치 사이의 골을 파냄
        for (i = [0:gt2_teeth-1]) {
            angle = i * 360 / gt2_teeth;
            rotate([0, 0, angle])
                translate([gt2_pitch_dia/2, 0, 0])
                    circle(r = tooth_radius, $fn = 24);
        }
    }
}

// GT2 풀리 링 (외치)
module gt2_pulley_ring() {
    difference() {
        union() {
            // 치형 링
            linear_extrude(height = pulley_ring_height)
                gt2_tooth_profile();

            // 하단 가이드 플랜지
            cylinder(d = gt2_outer_dia + 2, h = pulley_guide_height, $fn = 120);

            // 상단 가이드 플랜지
            translate([0, 0, pulley_ring_height - pulley_guide_height])
                cylinder(d = gt2_outer_dia + 2, h = pulley_guide_height, $fn = 120);
        }

        // 내부 구멍 (턴테이블 연결부 통과)
        translate([0, 0, -1])
            cylinder(d = pulley_ring_inner_dia, h = pulley_ring_height + 2, $fn = 120);
    }
}

// 턴테이블 볼트홀 패턴
module turntable_bolt_holes() {
    // 4개 볼트홀 - 코너 근처 배치
    bolt_x = tb_size/2 - tb_bolt_inset;
    bolt_y = tb_size/2 - tb_bolt_inset;

    positions = [
        [ bolt_x,  bolt_y],
        [-bolt_x,  bolt_y],
        [-bolt_x, -bolt_y],
        [ bolt_x, -bolt_y]
    ];

    for (pos = positions) {
        translate([pos[0], pos[1], -1])
            cylinder(d = tb_bolt_dia, h = bracket_thickness + 2, $fn = 24);
    }
}

// 중앙 브라켓 본체
module center_bracket() {
    difference() {
        union() {
            // 정사각형 베이스 플레이트
            translate([-bracket_size/2, -bracket_size/2, 0])
                cube([bracket_size, bracket_size, bracket_thickness]);

            // 풀리 링 (베이스 위에 돌출)
            translate([0, 0, bracket_thickness])
                gt2_pulley_ring();
        }

        // 턴테이블 볼트홀
        turntable_bolt_holes();

        // 중앙 케이블 통과홀
        translate([0, 0, -1])
            cylinder(d = 20, h = bracket_thickness + pulley_ring_height + 2, $fn = 48);
    }
}

// --- 십자 보강재 연결부 ---

// 십자 바 연결용 도브테일 (수) - 4방향
module cross_bar_connectors() {
    connector_width = 15;
    connector_depth = 8;
    connector_height = bracket_thickness;

    // 도브테일 프로파일 (사다리꼴)
    module dovetail_male() {
        linear_extrude(height = connector_height)
            polygon([
                [-connector_width/2 + 1, 0],
                [connector_width/2 - 1, 0],
                [connector_width/2, connector_depth],
                [-connector_width/2, connector_depth]
            ]);
    }

    // 4방향 (상하좌우)
    // 오른쪽 (+X)
    translate([bracket_size/2, 0, 0])
        rotate([0, 0, 0])
            dovetail_male();

    // 왼쪽 (-X)
    translate([-bracket_size/2, 0, 0])
        rotate([0, 0, 180])
            dovetail_male();

    // 위쪽 (+Y)
    translate([0, bracket_size/2, 0])
        rotate([0, 0, 90])
            dovetail_male();

    // 아래쪽 (-Y)
    translate([0, -bracket_size/2, 0])
        rotate([0, 0, -90])
            dovetail_male();
}

// --- 메인 ---

module model_a_center_bracket() {
    color("SteelBlue")
        center_bracket();

    color("SteelBlue", 0.8)
        cross_bar_connectors();
}

model_a_center_bracket();

// 디버그: 턴테이블 외형 표시
%translate([-tb_size/2, -tb_size/2, -tb_thickness])
    cube([tb_size, tb_size, tb_thickness]);
