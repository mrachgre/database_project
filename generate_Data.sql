

-- Create the "Nhan_vien" table
CREATE TABLE Nhan_vien (
    ID_nhan_vien SERIAL PRIMARY KEY,
    Ho VARCHAR(255) NOT NULL,
    Ten VARCHAR(255) NOT NULL,
    CCCD VARCHAR(12) NOT NULL UNIQUE,
    Cong_viec VARCHAR(255) NOT NULL,
    SDT VARCHAR(20) NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('female', 'male'))
);
-- Create the "May_tinh" table
CREATE TABLE May_tinh (
    ID_May SERIAL PRIMARY KEY,
    Tong_thoi_gian_su_dung INTEGER NOT NULL,
    Kha_dung BOOLEAN NOT NULL,
    Ban_phim VARCHAR(255) NOT NULL,
    Chuot VARCHAR(255) NOT NULL,
    CPU VARCHAR(255) NOT NULL,
    GPU VARCHAR(255) NOT NULL,
    Man_Hinh VARCHAR(255) NOT NULL
);
-- Create the "Nguoi_su_dung" table
CREATE TABLE "Nguoi_su_dung" (
    ID_User SERIAL PRIMARY KEY,
    SDT VARCHAR(20) NOT NULL,
    CCCD VARCHAR(12) NOT NULL UNIQUE,
    Ten_TK VARCHAR(255) NOT NULL UNIQUE,
    Mat_khau VARCHAR(255) NOT NULL,
    Thoi_gian_con_lai INTERVAL NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('female', 'male'))
);


-- Create the "San_pham" table
CREATE TABLE San_pham (
    ID_san_pham SERIAL PRIMARY KEY,
    Ten VARCHAR(255) NOT NULL,
    Gia NUMERIC(10, 2) NOT NULL,
    So_luong_con_lai INTEGER ,
    Loai_san_pham VARCHAR(100) CHECK (Loai_san_pham IN ('gio_choi', 'an_uong'))
);
-- Create the "Order" table
CREATE TABLE "Order" (
    ID_Order SERIAL PRIMARY KEY,
    ID_Nhan_vien INTEGER NOT NULL,
    ID_User INTEGER NOT NULL,
    ID_May INTEGER NOT NULL,
    Thoi_gian TIMESTAMP NOT NULL,
    Tong_gia_tri NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (ID_Nhan_vien) REFERENCES Nhan_vien(ID_nhan_vien),
    FOREIGN KEY (ID_User) REFERENCES "Nguoi_su_dung"(ID_User),
    FOREIGN KEY (ID_May) REFERENCES May_tinh(ID_May)
);

-- Create the "Chi_tiet_don_hang" table
CREATE TABLE Chi_tiet_don_hang (
    ID_Order INTEGER NOT NULL,
    ID_san_pham INTEGER NOT NULL,
    So_luong INTEGER NOT NULL,
    PRIMARY KEY (ID_Order, ID_san_pham),
    FOREIGN KEY (ID_Order) REFERENCES "Order"(ID_Order),
    FOREIGN KEY (ID_san_pham) REFERENCES San_pham(ID_san_pham)
);
-- Create the "Lich_su_truy_cap" table
CREATE TABLE Lich_su_truy_cap (
    ID_User INTEGER NOT NULL,
    ID_May INTEGER NOT NULL,
    Thoi_gian TIMESTAMP NOT NULL,
    PRIMARY KEY (ID_User, ID_May, Thoi_gian),
    FOREIGN KEY (ID_User) REFERENCES "Nguoi_su_dung"(ID_User),
    FOREIGN KEY (ID_May) REFERENCES May_tinh(ID_May)
);




INSERT INTO May_tinh(Tong_thoi_gian_su_dung, Kha_dung, Ban_phim, Chuot, CPU, GPU, Man_hinh )
SELECT 
    floor(random() * 100),
    (round(random())::int)::boolean,
    ('[0:4]={"Rapoo V500alloy","DareU EK87","MSI Vigor GK20 US","MSI Vigor GK30 US","Rapoo V500Pro"}'::text[])
    [floor(random() * 5)],
    ('[0:4]={"Logitech G502","Corsair Harpoon RGB","Dareu A960S","Asus TUF Gaming M3 ","Logitech G102 Gen 2 Lightsync"}'::text[])
    [floor(random() * 5)] ,
    ('[0:2]={"Intel Core i5-13400F","Intel Core i3-12100F","AMD Ryzen 5 7600"}'::text[])
    [floor(random() * 3)],
    ('[0:2]={"GTX 1650","RTX 2060","RTX 3060"}'::text[])
    [floor(random() * 3)],
    ('[0:4]={"Asus TUF Gaming VG249Q1A","ViewSonic Gaming VX2428J","MSI Gaming G274F","Samsung Odyssey G5 G51C LS27CG510EEXXV ","Asus Gaming ROG Strix XG249CM"}'::text[])
    [floor(random() * 5)] 
        FROM 
    generate_series (1,20) ;

INSERT INTO "Nguoi_su_dung"(SDT, CCCD, Ten_TK, Mat_khau,  thoi_gian_con_lai, Gender)
SELECT  
    to_char(random() * 10000000000, 'FM(+84)00-000-0000'),
    floor(random()* (999999999-100000000 + 1) + 100000000),
    substr(concat(md5(random()::text), md5(random()::text)), 0, 10),
    substr(concat(md5(random()::text), md5(random()::text)), 0, 8),
    Justify_interval(random() * interval '20 hour'),
    ('[0:1]={"male","female"}'::text[])
    [floor(random() * 2)]
FROM 
    generate_series (1,20);

INSERT INTO Nhan_vien(Ho, Ten, CCCD, Cong_viec, SDT, Gender)
SELECT 
    ('[0:4]={"Phan","Nguyen","Bui","Dinh","Truong"}'::text[])
    [floor(random() * 5)],
     ('[0:4]={"Duc","Mai","Hung","Tuan","Anh"}'::text[])
    [floor(random() * 5)],
    floor(random()* (999999999-100000000 + 1) + 100000000),
    ('[0:2]={"Quanly","Quet_don","Phuc_vu"}'::text[])
    [floor(random() * 3)],
    to_char(random() * 10000000000, 'FM(+84)00-000-0000'),
    ('[0:1]={"male","female"}'::text[])
    [floor(random() * 2)]
FROM 
    generate_series (1,5);

INSERT INTO San_pham(Ten, Gia, So_luong_con_lai, Loai_san_pham)
VALUES
( 'Bánh mì xá xíu', 15000, 10, 'an_uong' ),
( 'Cơm thập cẩm', 40000, 10, 'an_uong' ),
( 'Phở bò', 35000, 8, 'an_uong' ),
( 'Phở gà', 40000, 13, 'an_uong' ),
( 'Phở thập cẩm', 40000, 13, 'an_uong' ),
( 'Cơm trứng', 25000, 20, 'an_uong' ),
( 'Sting đỏ', 10000, 99, 'an_uong' ),
( 'Sting vàng', 10000, 99, 'an_uong' ),
( 'Coca', 10000, 99, 'an_uong' ),
( 'Sprite', 10000, 99, 'an_uong' ),
( 'Fanta', 10000, 99, 'an_uong' ),
( 'Gói 2 tiếng', 20000, 999, 'gio_choi' ),
( 'Gói 1 tiếng', 10000, 999, 'gio_choi' ),
( 'Gói 5 tiếng', 50000, 999, 'gio_choi' ),
( 'Gói đêm', 45000, 999, 'gio_choi' );

INSERT INTO "Order"(ID_Nhan_vien,  ID_User, ID_May, Thoi_gian, Tong_gia_tri)
SELECT
     floor(random() * (5 - 1 + 1) + 1),
     floor(random() * (20 - 1 +1 ) + 1),
     floor(random() * (20 - 1 +1 ) + 1),
     --timestamp '2024-01-01 13:00:00' + make_interval(days => (random() * 31):: int) + make_interval(months => (random() * 12):: int) + make_interval(hours => (random() * 24):: int) + make_interval(minute => (random() * 60):: int)  +  make_interval(second => (random() * 60):: int),
	 random() * (timestamp '2024-12-12 20:00:00' - timestamp '2024-01-01 10:00:00') + timestamp '2024-01-01 10:00:00',
      floor(random()* (2000000-100000 + 1) + 100000) 
FROM 
      generate_series(1, 50);

INSERT INTO Chi_tiet_don_hang( ID_order, ID_san_pham, So_luong )
SELECT
     floor(random() * (50-1+1)+1),
     floor(random() * (15 - 1 + 1) + 1),
     floor(random() * 10)
FROM
     generate_series(1, 50);

INSERT INTO Lich_su_truy_cap(ID_user, ID_May, Thoi_gian)
SELECT 
     floor(random() * (20-1+1)+1),
     floor(random() * (20-1+1)+1),
     random() * (timestamp '2024-12-12 20:00:00' - timestamp '2024-01-01 10:00:00') + timestamp '2024-01-01 10:00:00'
FROM 
     generate_series(1, 20);
	