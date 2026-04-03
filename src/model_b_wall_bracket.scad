// ============================================
// PiCanvas - 모델 B: 벽면 브라켓 + 모터 마운트
// ============================================

// --- 파라미터 ---

// 턴테이블 베어링
tb_size = 57;
tb_thickness = 10.5;
tb_bolt_inset = 5;
tb_bolt_dia = 4.2;     // M4 관통홀

// 모터 17HS4023
motor_w = 42.3;
motor_h = 42.3;
motor_d = 23.5;
motor_shaft_dia = 5;
motor_mount_pitch = 31;   // NEMA17 마운트홀 피치
motor_mount_hole = 3.2;   // M3 관통홀
motor_body_dia = 22;      // 모터 전면 보스 직경

// 벨트 시스템
belt_center_distance = 98;  // 축간 거리 (300mm 벨트)

// 모터 위치: 중심에서 belt_center_distance만큼 오프셋
// 모터를 오른쪽(+X)에 배치
motor_offset_x = belt_center_distance;
motor_offset_y = 0;

// 벽면 브라켓
wall_plate_thickness = 5;
wall_plate_margin = 15;    // 턴테이블 주변 여유
wall_anchor_dia = 6;       // 벽 앵커홀 직경
wall_anchor_count_head = 8; // 카운터싱크 직경

// 모터 마운트 (측면 클램프)
motor_clamp_wall = 4;      // 클램프 벽 두께
motor_clamp_gap = 1;       // 모터와의 간극
motor_clamp_height = motor_d - 3;  // 모터 높이보다 살짝 낮게

// Z 높이 맞춤
// 풀리 벨트 면이 모델A의 80T 풀리와 같은 높이여야 함
// 모델A: bracket_thickness(5) + pulley위치
// 모델B에서 모터 샤프트 높이를 맞춤
gt2_belt_width = 6;
bracket_a_thickness = 5;
pulley_ring_offset = bracket_a_thickness + 1;  // 풀리 벨트 중심 Z

// --- 모듈 ---

// 턴테이블 볼트홀 패턴
module tb_bolt_pattern(dia, depth) {
    bolt_x = tb_size/2 - tb_bolt_inset;
    bolt_y = tb_size/2 - tb_bolt_inset;
    positions = [
        [ bolt_x,  bolt_y],
        [-bolt_x,  bolt_y],
        [-bolt_x, -bolt_y],
        [ bolt_x, -bolt_y]
    ];
    for (pos = positions) {
        translate([pos[0], pos[1], -0.1])
            cylinder(d = dia, h = depth + 0.2, $fn = 24);
    }
}

// 벽면 앵커홀
module wall_anchor_holes() {
    // 턴테이블 바깥 코너 4곳
    anchor_offset = tb_size/2 + wall_plate_margin/2;
    positions = [
        [ anchor_offset,  anchor_offset],
        [-anchor_offset,  anchor_offset],
        [-anchor_offset, -anchor_offset],
        [ anchor_offset, -anchor_offset]
    ];
    for (pos = positions) {
        translate([pos[0], pos[1], -0.1]) {
            cylinder(d = wall_anchor_dia, h = wall_plate_thickness + 0.2, $fn = 24);
            // 카운터싱크
            cylinder(d = wall_anchor_count_head, h = 2.5, $fn = 24);
        }
    }
}

// 모터 측면 클램프 (축 수직, 샤프트 위 방향)
module motor_side_clamp() {
    inner_w = motor_w + motor_clamp_gap * 2;
    inner_h = motor_h + motor_clamp_gap * 2;
    outer_w = inner_w + motor_clamp_wall * 2;
    outer_h = inner_h + motor_clamp_wall * 2;

    difference() {
        // 외부 박스
        translate([-outer_w/2, -outer_h/2, 0])
            cube([outer_w, outer_h, motor_clamp_height]);

        // 모터 삽입 공간
        translate([-inner_w/2, -inner_h/2, -0.1])
            cube([inner_w, inner_h, motor_clamp_height + 0.2]);

        // 샤프트 통과 구멍 (위쪽)
        translate([0, 0, -0.1])
            cylinder(d = motor_body_dia + 2, h = motor_clamp_height + 0.2, $fn = 48);
    }

    // NEMA17 마운트 서포트 (바닥판)
    difference() {
        translate([-outer_w/2, -outer_h/2, 0])
            cube([outer_w, outer_h, motor_clamp_wall]);

        // 샤프트 통과
        translate([0, 0, -0.1])
            cylinder(d = motor_body_dia + 2, h = motor_clamp_wall + 0.2, $fn = 48);

        // NEMA17 마운트 볼트홀
        for (x = [-motor_mount_pitch/2, motor_mount_pitch/2])
            for (y = [-motor_mount_pitch/2, motor_mount_pitch/2])
                translate([x, y, -0.1])
                    cylinder(d = motor_mount_hole, h = motor_clamp_wall + 0.2, $fn = 24);
    }
}

// 연결 브릿지 (턴테이블 플레이트 → 모터 마운트)
module bridge() {
    bridge_width = 20;
    bridge_height = wall_plate_thickness;

    // 턴테이블 중심에서 모터 중심까지
    hull() {
        translate([tb_size/2, -bridge_width/2, 0])
            cube([1, bridge_width, bridge_height]);
        translate([motor_offset_x - motor_w/2 - motor_clamp_wall - motor_clamp_gap, -bridge_width/2, 0])
            cube([1, bridge_width, bridge_height]);
    }
}

// --- 메인 ---

module model_b_wall_bracket() {
    // 턴테이블 마운트 플레이트
    color("OrangeRed") {
        plate_size = tb_size + wall_plate_margin * 2;
        difference() {
            translate([-plate_size/2, -plate_size/2, 0])
                cube([plate_size, plate_size, wall_plate_thickness]);

            // 턴테이블 볼트홀 (고정판)
            tb_bolt_pattern(tb_bolt_dia, wall_plate_thickness);

            // 벽면 앵커홀
            wall_anchor_holes();

            // 중앙 관통홀 (케이블)
            translate([0, 0, -0.1])
                cylinder(d = 20, h = wall_plate_thickness + 0.2, $fn = 48);
        }
    }

    // 모터 마운트 브릿지
    color("OrangeRed")
        bridge();

    // 모터 클램프
    color("Tomato")
        translate([motor_offset_x, motor_offset_y, 0])
            motor_side_clamp();
}

// 단독 실행 시 프리뷰 → assembly.scad 사용 권장
