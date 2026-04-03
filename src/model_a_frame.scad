// ============================================
// PiCanvas - 모델 A: 액자 프레임 (6분할 + 도브테일)
// ============================================
// 분할 전략:
//   긴 변(362.66mm): 3등분 → 각 ~120.9mm (< 180mm OK)
//   짧은 변(228.25mm): 2등분 → 각 ~114.1mm (< 180mm OK)
//   총 6개 세그먼트, 각 분할선에 도브테일 조인트

// --- 파라미터 ---

// LCD 디스플레이
lcd_w = 350.66;
lcd_h = 216.25;
lcd_d = 3.2;

// 프레임
frame_bezel = 3;          // 전면 오버랩 (mm)
frame_wall = 6;           // 프레임 벽 두께
frame_depth = lcd_d + 3;  // 총 깊이: LCD 두께 + 후면 여유
frame_lip_depth = 2;      // 전면 립 두께 (Z방향)

frame_outer_w = lcd_w + frame_wall * 2;  // 362.66
frame_outer_h = lcd_h + frame_wall * 2;  // 228.25

// 분할 경계
// X축: 3등분 → -frame_outer_w/2, -frame_outer_w/6, +frame_outer_w/6, +frame_outer_w/2
split_x1 = -frame_outer_w / 6;  // ~-60.44
split_x2 =  frame_outer_w / 6;  // ~+60.44
split_y  = 0;                     // Y축: 중앙에서 2등분

// 각 세그먼트 크기 검증
seg_w = frame_outer_w / 3;  // ~120.89 < 180 OK
seg_h = frame_outer_h / 2;  // ~114.13 < 180 OK

// 도브테일 (십자 보강재 연결용)
dt_width = 15;
dt_depth = 8;
dt_taper = 1;
dt_clearance = 0.2;

// 세그먼트간 도브테일 (프레임 분할선)
sdt_width = 10;
sdt_depth = 4;
sdt_taper = 0.8;
sdt_clearance = 0.08;  // 0.15 → 0.08 (가결합 가능하도록 타이트하게)

// 도브테일 위치: 프레임 바깥쪽 가장자리 (LCD 간섭 방지)
// frame_wall=6, 도브테일을 외벽 쪽에 배치
sdt_y_offset_top = frame_outer_h/2 - sdt_width/2 - 0.5;  // 상변 바깥쪽
sdt_y_offset_bot = frame_outer_h/2 - sdt_width/2 - 0.5;  // 하변 바깥쪽
sdt_x_offset = frame_outer_w/2 - sdt_width/2 - 0.5;      // 좌/우변 바깥쪽

// --- 모듈 ---

// 십자 보강재용 도브테일 슬롯
module dovetail_slot() {
    w = dt_width + dt_clearance * 2;
    d = dt_depth + dt_clearance;
    translate([0, 0, -0.5])
    linear_extrude(height = frame_depth + 1)
        polygon([
            [-w/2 + dt_taper, 0],
            [w/2 - dt_taper, 0],
            [w/2, d],
            [-w/2, d]
        ]);
}

// 세그먼트간 도브테일 수 (male)
module seg_dovetail_male() {
    linear_extrude(height = frame_depth)
        polygon([
            [-sdt_width/2 + sdt_taper, 0],
            [sdt_width/2 - sdt_taper, 0],
            [sdt_width/2, sdt_depth],
            [-sdt_width/2, sdt_depth]
        ]);
}

// 세그먼트간 도브테일 암 (female) - 빼기용
module seg_dovetail_female() {
    c = sdt_clearance;
    w = sdt_width + c * 2;
    d = sdt_depth + c;
    translate([0, 0, -0.5])
    linear_extrude(height = frame_depth + 1)
        polygon([
            [-w/2 + sdt_taper, -c],
            [w/2 - sdt_taper, -c],
            [w/2, d],
            [-w/2, d]
        ]);
}

// X 분할선의 도브테일 (Y방향으로 배치)
// 상변/하변 프레임 벽에 각 1개
module x_split_dovetails_male(x_pos) {
    // 상변 프레임 벽 (Y+쪽)
    translate([x_pos, frame_outer_h/2 - frame_wall/2, 0])
        rotate([0, 0, 90])
            seg_dovetail_male();
    // 하변 프레임 벽 (Y-쪽)
    translate([x_pos, -(frame_outer_h/2 - frame_wall/2), 0])
        rotate([0, 0, -90])
            seg_dovetail_male();
}

module x_split_dovetails_female(x_pos) {
    translate([x_pos, frame_outer_h/2 - frame_wall/2, 0])
        rotate([0, 0, 90])
            seg_dovetail_female();
    translate([x_pos, -(frame_outer_h/2 - frame_wall/2), 0])
        rotate([0, 0, -90])
            seg_dovetail_female();
}

// Y 분할선의 도브테일 (X방향으로 배치)
// 좌변/우변 + 중간에도 배치
module y_split_dovetails_male(y_pos) {
    // 좌변 프레임 벽
    translate([-(frame_outer_w/2 - frame_wall/2), y_pos, 0])
        rotate([0, 0, 0])
            seg_dovetail_male();
    // 우변 프레임 벽
    translate([(frame_outer_w/2 - frame_wall/2), y_pos, 0])
        rotate([0, 0, 180])
            seg_dovetail_male();
}

module y_split_dovetails_female(y_pos) {
    translate([-(frame_outer_w/2 - frame_wall/2), y_pos, 0])
        rotate([0, 0, 0])
            seg_dovetail_female();
    translate([(frame_outer_w/2 - frame_wall/2), y_pos, 0])
        rotate([0, 0, 180])
            seg_dovetail_female();
}

// 전체 프레임 (분할 전)
module full_frame() {
    difference() {
        // 외부 쉘
        translate([-frame_outer_w/2, -frame_outer_h/2, 0])
            cube([frame_outer_w, frame_outer_h, frame_depth]);

        // LCD 개구부 (전면에서 bezel만큼 안쪽)
        translate([-(lcd_w - frame_bezel*2)/2, -(lcd_h - frame_bezel*2)/2, -0.1])
            cube([lcd_w - frame_bezel*2, lcd_h - frame_bezel*2, frame_lip_depth + 0.2]);

        // LCD 안착부 (립 뒤에 LCD 크기 홈)
        translate([-lcd_w/2, -lcd_h/2, frame_lip_depth])
            cube([lcd_w, lcd_h, frame_depth]);

        // 십자 보강재 도브테일 슬롯 - 4개
        translate([lcd_w/2 + frame_wall, 0, 0])
            rotate([0, 0, 180]) dovetail_slot();
        translate([-(lcd_w/2 + frame_wall), 0, 0])
            dovetail_slot();
        translate([0, lcd_h/2 + frame_wall, 0])
            rotate([0, 0, -90]) dovetail_slot();
        translate([0, -(lcd_h/2 + frame_wall), 0])
            rotate([0, 0, 90]) dovetail_slot();
    }
}

// 커팅 박스 (intersection용)
module cut_box(x_min, y_min, x_max, y_max) {
    translate([x_min, y_min, -1])
        cube([x_max - x_min, y_max - y_min, frame_depth + 2]);
}

// --- 6개 세그먼트 ---
// 배치: [TL][TC][TR] (상단 좌/중/우)
//        [BL][BC][BR] (하단 좌/중/우)

hw = frame_outer_w / 2;
hh = frame_outer_h / 2;

// 상단 좌 (TL): x=-hw ~ split_x1, y=0 ~ +hh
module frame_seg_TL() {
    difference() {
        union() {
            intersection() {
                full_frame();
                cut_box(-hw, 0, split_x1, hh);
            }
            // 도브테일 수: 오른쪽(split_x1)에 male → TC와 결합
            // 도브테일 수: 아래쪽(y=0)에 male → BL과 결합
        }
        // X분할선(split_x1): 이 세그먼트가 male 제공 → 없으면 female 빼기
        // Y분할선(y=0): 이 세그먼트가 male 제공
    }
    // X 분할: TL이 오른쪽에 male 돌출
    intersection() {
        translate([split_x1, sdt_y_offset_top, 0])
            seg_dovetail_male();
        cut_box(split_x1, 0, split_x1 + sdt_depth + 1, hh);
    }
    // Y 분할: TL이 아래쪽에 male 돌출
    intersection() {
        translate([-sdt_x_offset, 0, 0])
            rotate([0, 0, -90])
                seg_dovetail_male();
        cut_box(-hw, -sdt_depth - 1, split_x1, 0);
    }
}

// 상단 중앙 (TC): x=split_x1 ~ split_x2, y=0 ~ +hh
module frame_seg_TC() {
    difference() {
        intersection() {
            full_frame();
            cut_box(split_x1, 0, split_x2, hh);
        }
        // 왼쪽(split_x1)에 female: TL의 male을 받음
        translate([split_x1, sdt_y_offset_top, 0])
            seg_dovetail_female();
    }
    // 오른쪽(split_x2)에 male: TR과 결합
    intersection() {
        translate([split_x2, sdt_y_offset_top, 0])
            seg_dovetail_male();
        cut_box(split_x2, 0, split_x2 + sdt_depth + 1, hh);
    }
    // Y 분할: 아래쪽에 male → BC와 결합 (이 구간은 프레임 벽이 없으므로 생략)
}

// 상단 우 (TR): x=split_x2 ~ +hw, y=0 ~ +hh
module frame_seg_TR() {
    difference() {
        union() {
            intersection() {
                full_frame();
                cut_box(split_x2, 0, hw, hh);
            }
        }
        // 왼쪽(split_x2)에 female: TC의 male을 받음
        translate([split_x2, sdt_y_offset_top, 0])
            seg_dovetail_female();
    }
    // Y 분할: 아래쪽에 male → BR과 결합
    intersection() {
        translate([sdt_x_offset, 0, 0])
            rotate([0, 0, 90])
                seg_dovetail_male();
        cut_box(split_x2, -sdt_depth - 1, hw, 0);
    }
}

// 하단 좌 (BL): x=-hw ~ split_x1, y=-hh ~ 0
module frame_seg_BL() {
    difference() {
        intersection() {
            full_frame();
            cut_box(-hw, -hh, split_x1, 0);
        }
        // 위쪽(y=0)에 female: TL의 male을 받음
        translate([-sdt_x_offset, 0, 0])
            rotate([0, 0, -90])
                seg_dovetail_female();
    }
    // 오른쪽(split_x1)에 male → BC와 결합
    intersection() {
        translate([split_x1, -(sdt_y_offset_top), 0])
            seg_dovetail_male();
        cut_box(split_x1, -hh, split_x1 + sdt_depth + 1, 0);
    }
}

// 하단 중앙 (BC): x=split_x1 ~ split_x2, y=-hh ~ 0
module frame_seg_BC() {
    difference() {
        intersection() {
            full_frame();
            cut_box(split_x1, -hh, split_x2, 0);
        }
        // 왼쪽(split_x1)에 female: BL의 male을 받음
        translate([split_x1, -(sdt_y_offset_top), 0])
            seg_dovetail_female();
    }
    // 오른쪽(split_x2)에 male → BR과 결합
    intersection() {
        translate([split_x2, -(sdt_y_offset_top), 0])
            seg_dovetail_male();
        cut_box(split_x2, -hh, split_x2 + sdt_depth + 1, 0);
    }
}

// 하단 우 (BR): x=split_x2 ~ +hw, y=-hh ~ 0
module frame_seg_BR() {
    difference() {
        union() {
            intersection() {
                full_frame();
                cut_box(split_x2, -hh, hw, 0);
            }
        }
        // 왼쪽(split_x2)에 female: BC의 male을 받음
        translate([split_x2, -(sdt_y_offset_top), 0])
            seg_dovetail_female();
        // 위쪽(y=0)에 female: TR의 male을 받음
        translate([sdt_x_offset, 0, 0])
            rotate([0, 0, 90])
                seg_dovetail_female();
    }
}

// --- 메인: 어셈블리 뷰 ---

module model_a_frame_assembly() {
    color("SlateGray", 0.9)     frame_seg_TL();
    color("DarkSlateGray", 0.9) frame_seg_TC();
    color("SlateGray", 0.9)     frame_seg_TR();
    color("DarkSlateGray", 0.9) frame_seg_BL();
    color("SlateGray", 0.9)     frame_seg_BC();
    color("DarkSlateGray", 0.9) frame_seg_BR();
}

// 단독 실행 시 프리뷰 → assembly.scad 사용 권장
