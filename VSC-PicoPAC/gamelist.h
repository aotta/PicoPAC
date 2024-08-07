/*
//                       PicoPAC MultiCART by Andrea Ottaviani 2024
//
//  VIDEOPAC  multicart based on Raspberry Pico board -
//
//  More info on https://github.com/aotta/ 
//
//   parts of code are directly from the A8PicoCart project by Robin Edwards 2023
//  
//   Needs to be a release NOT debug build for the cartridge emulation to work
// 
//   Edit myboard.h depending on the type of flash memory on the pico clone//
//
//   v. 1.0 2024-08-05 : Initial version for Pi Pico 
//
*/

char gamelist[255][32]= {
// 12345678901234567890123456789012  
  "vp_60_16.bin",  // pag 1
  "br_16.bin",
  "br_17.bin",
  "br_19.BIN",
  "br_21.BIN",
  "br_46.BIN",
  "br_50.BIN",
  "br_54.BIN",    
  "br_55.BIN",       // pag 2
  "br_58.BIN",
  "br_clay-pigeon.bin",
  "br_comando-noturno.bin",
  "br_frogger.bin",
  "br_popeye.bin",
  "br_super-cobra.bin",
  "csv1.bin",
  "csv2.bin",   // pag 3
  "deat race rco4.bin",  // to correct
  "helicopter rescue.bin", // to correct
  "im_atlantis.bin",
  "im_demon-attack.bin",
  "jo_basket-bowling_pl.bin",
  "jo_billard_pl.bin",
  "jo_chez-maxime.bin",
"jo_demon-attack_pl.bin",     // pag 4
"jo_exojet_pl.bin",
"jo_flipper_pl.bin",
"jo_le-tresor-englouti_pl.bin",
"jo_moto-crash_pl.bin",
"jo_syracuse.bin",
"mod_01pl.bin",
"mod_05_g7400.bin",
"mod_06pl.bin",    // pag 5
"mod_11pl.bin",
"mod_14fix.bin",
"mod_19_g7400.bin",
"mod_20pl.bin",
"mod_24pl.bin",
"mod_28fix.bin",
"mod_30fix.bin",
"mod_31_g7400.bin",   // pag 6
"mod_35pl_fix.bin",
"mod_36fix.bin",
"mod_40_g7400.bin",
"mod_43pl.bin",
"mod_55pl.bin",
"mod_br21_fix.bin",
"mod_demon-attack_pl.bin",
"mod_moto-crash_g7000.bin",   // pag 7
"mod_playtag_fix.bin",
"mod_tutankham_fix.bin",
"mod_vp9_examples.bin",
"mod_vp31_examples.bin",
"mousecat.bin",
"new_amok.bin",
"new_amok_alt.bin",
"new_calculator.bin",     // pag 8
"new_helicopter_buzzword.bin",
"new_jg-munchkin.bin",
"new_kc-pacman.bin",
"new_kc-pacvid.bin",
"new_ktaa.bin",
"new_ktaa-demo1.bin",
"new_ktaa-demo2.bin",
"new_mrroboto.bin",     // pag 9
"new_planet-lander.bin",
"new_pong.bin",
"new_pong_all.bin",
"new_ppp-o2em.bin",
"new_puzzle-piece-panic.bin",
"new_route66.bin",
"norseman /europe", // to fix
"ntsc_57.bin",             // pag 10
"ntsc_chez-maxime.bin",
"ntsc_exojet_pl.bin",
"ntsc_interpol.bin",
"ntsc_moto-crash.bin",
"ntsc_shark-hunter.bin",
"ntsc_tutankham.bin",
"o2_06.bin",
"o2_07.bin",                // pag 11
"o2_10.bin",
"o2_11.bin",
"o2_14.bin",
"o2_16.bin",
"o2_19.bin",
"o2_21.bin",
"o2_30.bin",
"o2_33.bin",         // pag 12
"o2_35.bin",
"o2_38.bin",
"o2_39.bin",
"o2_40.bin",
"o2_41.bin",
"o2_43.bin",
"o2_45.bin",
"o2_46.bin",        // pag 13
"o2_47.bin",
"o2_48.bin",
"o2_48alt.bin",
"pal_acrobats.bin",
"pal_flashpoint.bin",
"pal_nimble-numbers-ned.bin",
"pal_type-and-tell.bin",
"pb_frogger.bin",    // pag 14
"pb_popeye.bin",
"pb_q-bert.bin",
"pb_super-cobra.bin",
"pr_clay-pigeon_pl.bin",
"pr_clay-pigeon_pl_alt.bin",
"pr_interpol.bin",
"pr_martian-threat.bin",
"pr_martian-threat_alt.bin",    // pag 15
"pr_mission-impossible.bin",
"pr_nightfighter.bin",
"pr_pinball.bin",
"pr_playtag.bin",
"pr_red-baron.bin",
"pr_red-baron_alt.bin",
"pr_robot-city.bin",
"pr_shark-hunter.bin",   // pag 16
"pr_spiderman.bin",
"pr_spiderman_alt.bin",
"pr_tutankham.bin",
"vp_01.bin",
"vp_01hack.bin",
"vp_01pl.bin",
"vp_02.bin",
"vp_03.bin",   // pag 17
"vp_04.bin",
"vp_05.bin",
"vp_06.bin",
"vp_06pl.bin",
"vp_07.bin",
"vp_08.bin",
"vp_09.bin",
"vp_10.bin",     // pag 18
"vp_11.bin",
"vp_11alt.bin",
"vp_11pl.bin",
"vp_12.bin",
"vp_13.bin",
"vp_14.bin",
"vp_15.bin",
"vp_16.bin",    // pag 19
"vp_17.bin",
"vp_18.bin",
"vp_19.bin",
"vp_20.bin",
"vp_20pl.bin",
"vp_21.bin",
"vp_22.bin",
"vp_22hack.bin",    // pag 20
"vp_23.bin",
"vp_24.bin",
"vp_24pl.bin",
"vp_25.bin",
"vp_26.bin",
"vp_27.bin",
"vp_28.bin",
"vp_29.bin",    // pag 21
"vp_30.bin",
"vp_31.bin",
"vp_32.bin",
"vp_33.bin",
"vp_33alt.bin",
"vp_34.bin",
"vp_34pl.bin",
"vp_35.bin",     // pag 22
"vp_35pl.bin",
"vp_36.bin",
"vp_37.bin",
"vp_38.bin",
"vp_39.bin",
"vp_39pl.bin",
"vp_40.bin",   
"vp_41.bin",   // pag 23
"vp_42.bin",
"vp_43.bin",
"vp_43pl.bin",
"vp_44.bin",
"vp_45.bin",
"vp_46.bin",
"vp_47.bin",
"vp_48.bin",    // pag 24
"vp_49.bin",
"vp_50.bin",
"vp_51pl.bin",
"vp_52pl.bin",
"vp_53.bin",
"vp_53pl.bin",
"vp_54.bin",
"vp_54pl.bin",    // pag 25
"vp_55.bin",
"vp_55_12.bin",
"vp_55_12fix.bin",
"vp_56pl.bin",
"vp_57.bin",
"vp_58_12.bin",
"vp_59_16.bin",
"vp_60_16.bin",    // pag 26
};

