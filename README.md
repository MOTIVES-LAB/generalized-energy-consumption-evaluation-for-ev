# Data and Code for Generalized Energy Consumption Evaluation for BEVs  

## Overview  
**Standard energy consumption testing** is the only publicly available quantifiable measure of battery electric vehicle (BEV) energy consumption, and it plays a crucial role in promoting transparency and accountability in the electrified automotive industry. However, significant discrepancies between standard testing and real-world driving conditions have hindered accurate energy and environmental assessments of BEVs, affecting their broader adoption.  
To address this issue, we propose a data-driven evaluation method to better characterize BEV energy consumption. We introduce a novel energy consumption metric, the **Generalized Energy Consumption Rates (GECRs)**, which decouples the impact of different driving profiles, making it applicable to various driving conditions. This repository contains the data and source code designed to validate the feasibility of GECRs.  
Our results demonstrate the significant potential of the proposed approach in enhancing public awareness of BEV energy consumption through standard testing. Additionally, GECRs provide a reliable **fundamental model** for understanding and assessing BEV energy consumption performance in real-world scenarios.

- **Cover of Cell Press Journal featuring our study**
<p align="center">
  <img src="https://github.com/MOTIVES-LAB/generalized-energy-consumption-evaluation-for-ev/blob/main/figures/cover.tif%20(1).jpg" alt="drawing" width="413"/>
</p>  

- **Main Principle Diagram** 
<p align="center">
  <img src="https://github.com/MOTIVES-LAB/bev-energy-consumption-estimator/blob/main/figures/schemetic.svg" alt="drawing" />
</p>

  


## Contents
- `data/lab_data_m1`: Directory containing the datasets of 34 laboratory cycle tests used in the study，including CLTC, UDDS, HWFET, US06, NYCC, WLTC, Artemis motorway, Artemis rural, Artemis urban, JC08, and 20, 35, 50, 65, 80, 95, 110 km/h constant speed driving.  
- `data/real_world_data`: Directory containing the datasets of 106 realword driving trips used in the study.  
- `functions/`: Directory containing the source code for functions used in this study.  
- `CharacterizeGECI_lab.m`: This file characterizes GECRs from an existing standard test procedure and estimates the energy consumption rates (ECRs) for 28 other laboratory test cycles.
- `GECI_test_realword.m`: This file uses the laboratory characterized GECRs and estimates the energy consumption rates (ECRs) for 106 realworld driving trips.
- `README.md`: This file, providing an overview and instructions for the repository.  

## References
- Please cite the following paper when you use GECR model:  
`
Yuan, Xinmei, et al. "Data-driven evaluation of electric vehicle energy consumption for generalizing standard testing to real-world driving." Patterns 5.4 (2024).  
`\
Available at: [Patterns (Cell Press)](https://doi.org/10.1016/j.patter.2024.100950)  
- Video introduction:  
`
A Brief Introduction to Generalized Energy Consumption Rates  
`\
Available at: [Youtube](https://www.youtube.com/watch?v=vmJZik6mKlA&t=61s)  
`
可泛化能耗率介绍 
`\
Available at: [b站](https://www.bilibili.com/video/BV1um421V7Z8/?share_source=copy_web&vd_source=5c67b4335d1b513776dc2660713291aa)   
- Online app:  
`
English version:  
`
[Github](https://motives-lab.github.io/GECR_web/)  
`
中文版:
`
http://47.92.126.206/

## Erratum

In the section "GECR model" under "EXPERIMENTAL PROCEDURES," of this paper , it is stated that "v_{th} is the threshold velocity for low- and high-speed driving, which is selected to be 15 km/h"
However, in this code, this parameter was mistakenly used as 15 m/s (equivalent to 54 km/h). Consequently, all results presented in the paper are based on v_{th}=54km/h.
This error does not affect the methods or conclusions of the study， and we have corrected this error.
We apologize for any confusion this may have caused. Thank you for your understanding.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer
This software is provided as freeware, intended solely for non-commercial, educational, and research purposes. It must not be used for any commercial purposes without prior authorization from the software developer. Any use for commercial purposes without such authorization will render you and the users responsible for any resultant liabilities, and the software developer and the platform will not be held responsible for any consequences arising therefrom.
Users assume all risks associated with the use of this software. The developer and associated platforms disclaim any liability for special, incidental, direct, or indirect damages arising out of or in connection with the use or inability to use the software. This includes, but is not limited to, any loss of data or property, and any resulting or related liabilities to the user or any third parties.
By downloading or using this software, you signify your agreement to these terms.

## Contact Us
Please contact us if you need further technical support or search for cooperation. Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.\
Email contact: &nbsp; [MOTIVES Lab](mailto:motives.lab@gmail.com?subject=[GitHub]%20GECR), &nbsp; [Xinmei Yuan](mailto:yuan@jlu.edu.cn?subject=[GitHub]%20GECR).
  
<p align="center">
  <img src="https://github.com/MOTIVES-LAB/generalized-energy-consumption-evaluation-for-ev/blob/main/figures/new_logo_trans.png" alt="drawing" width="200"/>
</p>  
