clear;close all;

sonne1=[34 27 27 2];
theworld=[20 20 20 1];
revelle=[18 16.5 16.5 0.05];

oceanflux('/scratch/uni/u237/users/smichel/or_data/investigator/joint_investigator_disdro_2016T01-2016T02_colloc_cont_ww_na_ancillary_checked.txt', 22.1,31.4,31.4,6.9);
oceanflux('/scratch/uni/u237/users/smichel/or_data/investigator/joint_investigator_disdro_2016V01-2016V02_colloc_cont_ww_na_ancillary_checked.txt', 22.1,31.4,31.4,6.9);
oceanflux('/scratch/uni/u237/users/smichel/or_data/investigator/joint_investigator_disdro_2016V02-2016V03_colloc_cont_ww_na_ancillary_checked.txt', 22.1,31.4,31.4,6.9);
oceanflux('/scratch/uni/u237/users/smichel/or_data/investigator/joint_investigator_disdro_2016V03-2016V04_colloc_cont_ww_na_ancillary_checked.txt', 22.1,31.4,31.4,6.9);

oceanflux('/scratch/uni/u237/users/smichel/or_data/rogerrevelle/joint_rogerrevelle_disdro_2016M08-2016M09_colloc_cont_ww_na_ancillary_checked.txt', revelle(1),revelle(2),revelle(3),revelle(4));
oceanflux('/scratch/uni/u237/users/smichel/or_data/sonne2/joint_sonne2_disdro_SO237-SO256_colloc_cont_ancillary_checked.txt', 34,27,27,2);
oceanflux('/scratch/uni/u237/users/smichel/or_data/theworld/joint_theworld_disdro_2017V01-2017V02_colloc_cont_ww_nc_ancillary_checked.txt',20,20,20,1);

oceanflux('/scratch/uni/u237/users/smichel/or_data/polarstern/joint_PSDISDRO_PS76-PS80_colloc_cont_ww_na_ancillary_checked.txt', 39,29,29,5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/polarstern/joint_PSDISDRO_PS81-PS83_colloc_cont_ww_na_ancillary_checked.txt', 39,29,29,5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/polarstern/joint_PSDISDRO_PS85-PS87_colloc_cont_ww_na_ancillary_checked.txt', 39,29,29,5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/polarstern/joint_PSDISDRO_PS88-PS90_colloc_cont_ww_na_ancillary_checked.txt', 39,29,29,5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/polarstern/joint_PSDISDRO_PS92-PS94_colloc_cont_ww_na_ancillary_checked.txt', 39,29,29,5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/polarstern/joint_PSDISDRO_PS95-PS97_colloc_cont_ww_na_ancillary_checked.txt', 39,29,29,5);

oceanflux('/scratch/uni/u237/users/smichel/or_data/sonne1/joint_sonne_disdro_2012M09-2012M10_colloc_cont_ww_na_ancillary_checked.txt',34,27,27,2);

oceanflux('/scratch/uni/u237/users/smichel/or_data/meteor/joint_METEORDISDRO_M105-M108_colloc_cont_ww_na_ancillary_checked.txt', 37.5,37.5,37.5,2.5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/meteor/joint_METEORDISDRO_M109-M116_colloc_cont_ww_na_ancillary_checked.txt', 37.5,37.5,37.5,2.5);
oceanflux('/scratch/uni/u237/users/smichel/or_data/meteor/joint_METEORDISDRO_M117-M124_colloc_cont_ww_na_ancillary_checked.txt', 37.5,37.5,37.5,2.5);