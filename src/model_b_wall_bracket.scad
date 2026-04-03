// ============================================
// PiCanvas - 모델 B: 벽면 브라켓 + 모터 마운트
// ============================================
// Z 배치:
//   Z=0         : 벽면 플레이트 기준면 (턴테이블 고정판 장착면)
//   Z=0 ~ +5    : 벽면 플레이트 (벽쪽, 앵커홀 카운터싱크)
//   Z=0 ~ -clamp: 모터 클램프 + 브릿지 (프레임쪽으로 돌출)
//   모터 샤프트는 -Z 방향 (프레임쪽, 풀리와 벨트 연결)

// --- 파라미터 ---

// 턴테이블 베어링
tb_size = 57;
tb_thickness = 10.5;
tb_bolt_inset = 5;
tb_bolt_dia = 4.2;

// 모터 17HS4023
motor_w = 42.3;
motor_h = 42.3;
motor_d = 23.5;
motor_shaft_dia = 5;
motor_mount_pitch = 31;
motor_mount_hole = 3.2;
motor_body_dia = 22;

// 벨트 시스템
belt_center_distance = 98;
motor_offset_x = belt_center_distance;
motor_offset_y = 0;

// 벽면 브라켓
wall_plate_thickness = 5;
wall_plate_margin = 15;
wall_anchor_dia = 6;
wall_anchor_count_head = 8;

// 모터 마운트 (측면 클램프)
motor_clamp_wall = 4;
motor_clamp_gap = 1;
motor_clamp_height = motor_d - 3;

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
            // 카운터싱크 (벽쪽 = +Z쪽)
            translate([0, 0, wall_plate_thickness - 2.5 + 0.1])
                cylinder(d = wall_anchor_count_head, h = 2.5 + 0.1, $fn = 24);
        }
    }
}

// 모터 측면 클램프 (-Z방향으로 돌출, 샤프트가 -Z를 향함)
module motor_side_clamp() {
    inner_w = motor_w + motor_clamp_gap * 2;
    inner_h = motor_h + motor_clamp_gap * 2;
    outer_w = inner_w + motor_clamp_wall * 2;
    outer_h = inner_h + motor_clamp_wall * 2;

    // -Z 방향으로 빌드 (프레임쪽)
    translate([0, 0, -motor_clamp_height])
    difference() {
        // 외부 박스
        translate([-outer_w/2, -outer_h/2, 0])
            cube([outer_w, outer_h, motor_clamp_height]);

        // 모터 삽입 공간
        translate([-inner_w/2, -inner_h/2, -0.1])
            cube([inner_w, inner_h, motor_clamp_height + 0.2]);

        // 샤프트 통과 구멍
        translate([0, 0, -0.1])
            cylinder(d = motor_body_dia + 2, h = motor_clamp_height + 0.2, $fn = 48);
    }

    // NEMA17 마운트 서포트 (Z=0 면 = 벽면 플레이트와 동일 기준면)
    translate([0, 0, -motor_clamp_wall])
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

// 연결 브릿지 (-Z 방향, 프레임쪽)
module bridge() {
    bridge_width = 20;
    bridge_thickness = wall_plate_thickness;

    translate([0, 0, -bridge_thickness])
    hull() {
        translate([tb_size/2, -bridge_width/2, 0])
            cube([1, bridge_width, bridge_thickness]);
        translate([motor_offset_x - motor_w/2 - motor_clamp_wall - motor_clamp_gap, -bridge_width/2, 0])
            cube([1, bridge_width, bridge_thickness]);
    }
}

// --- 메인 ---

module model_b_wall_bracket() {
    // 벽면 플레이트 (+Z = 벽쪽)
    color("OrangeRed") {
        plate_size = tb_size + wall_plate_margin * 2;
        difference() {
            translate([-plate_size/2, -plate_size/2, 0])
                cube([plate_size, plate_size, wall_plate_thickness]);

            tb_bolt_pattern(tb_bolt_dia, wall_plate_thickness);
            wall_anchor_holes();

            // 중앙 관통홀 (케이블)
            translate([0, 0, -0.1])
                cylinder(d = 20, h = wall_plate_thickness + 0.2, $fn = 48);
        }
    }

    // 모터 마운트 브릿지 (-Z = 프레임쪽)
    color("OrangeRed")
        bridge();

    // 모터 클램프 (-Z = 프레임쪽)
    color("Tomato")
        translate([motor_offset_x, motor_offset_y, 0])
            motor_side_clamp();
}

// 단독 실행 시 프리뷰 → assembly.scad 사용 권장
