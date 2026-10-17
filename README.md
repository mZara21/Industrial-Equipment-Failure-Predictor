
# Predictive Maintenance & Fault Diagnosis

![MATLAB](https://img.shields.io/badge/MATLAB-e16737?style=for-the-badge&logo=mathworks&logoColor=white)
![Neural Networks](https://img.shields.io/badge/Algorithms-Neural__Networks-orange?style=for-the-badge)
![Case-Based Reasoning](https://img.shields.io/badge/Algorithms-Case__Based__Reasoning-007396?style=for-the-badge)
![Data Analysis](https://img.shields.io/badge/Data-Analysis-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)

This repository contains an AI-driven analytical approach for predictive maintenance in industrial engines. Developed using **MATLAB**, the project aims to classify the operational state of machinery (Normal, Electrical Failure, or Mechanical Failure) by analyzing raw sensor data. The solution implements two distinct AI paradigms: a **Case-Based Reasoning (CBR)** system and **Feedforward Neural Networks (Deep Learning Toolbox)**.

## Dataset Overview

The dataset consists of multiple continuous and categorical features collected from industrial equipment sensors to diagnose faults. 

### Sensor Features (Continuous)
- **`temperature`**: Machine operating temperature (universal fault symptom).
- **`vibration`**: Measured vibration levels (critical for detecting mechanical imbalances).
- **`rotation_speed`**: Operational speed of the machine.
- **`voltage` & `current`**: Electrical characteristics (current is the clearest sign of electrical issues).
- **`pressure`**: System pressure levels for auxiliary systems.
- **`noise_level`**: Acoustic emissions during operation.
- **`efficiency`**: Calculated efficiency metric of the equipment.
- **`load_val` & `torque`**: Physical load and torque (measures effective mechanical effort).

### Operational Features (Categorical & Ordinal)
- **`maintenance_level`**: Ordinal maintenance indicators (Low=0, Medium=1, High=2).
- **`operating_mode`**: Ordinal operational stress (Idle=0, Normal=1, Overload=2).
- **`cooling_type`**: Binary mechanism active (Air=0, Oil=1).
- **`sensor_status`**: Binary flag of the monitoring sensors (OK=0, Warning=1).

### Target Variable
- **`class_cat`**: The actual condition of the machine:
  - `Normal`
  - `MechanicalFailure`
  - `ElectricalFailure`

## Core AI Implementations

The project required strict data preprocessing, including dealing with missing values using the median and applying Min-Max normalization to ensure all continuous variables were scaled to a `[0, 1]` range. 

### 1. Case-Based Reasoning (CBR) System
The CBR cycle was built from scratch to retrieve similar historical cases based on weighted distances.
* **Weighted Similarity (Retrieve):** Features were assigned specific weights based on their physical relevance (e.g., `Vibration` was weighted highest at 3.0, and `Current` at 2.8).
* **Neural Network Adaptation (Reuse):** A dedicated neural network (10 hidden neurons, `trainlm` function) receives Vibration, Rotation Speed, and Voltage to predict and adapt the Temperature attribute of the retrieved case
* **Human Validation (Revise & Retain):** The system descales the temperature for human evaluation. Verified cases are persisted in the knowledge base, ignoring entries with excessive missing values to avoid noise propagation.

### 2. Feedforward Neural Networks
Using MATLAB's Deep Learning Toolbox, various network topologies, training functions, and activation functions were thoroughly tested.
* **Best Topology:** A deep architecture with 3 hidden layers `[10 5 3]` proved highly efficient.
* **Best Training Function:** Bayesian Regularization (`trainbr`) achieved a flawless 100% accuracy on the test set, eliminating overfitting.
* **Activation Functions:** Sigmoid functions (`tansig` and `logsig`) along with `purelin` achieved near-perfect accuracy, while rigid functions (`hardlim`) failed completely.
* **Target Mapping:** Classes were mapped using a One-Hot Encoding matrix.

## Conclusions
Both the Neural Networks and the CBR system achieved 100% accuracy on the final test sets when properly configured. However, while Neural Networks were far more resilient to raw, non-normalized data, they function as a "black box". In contrast, the CBR system collapsed without normalization (dropping to ~16% accuracy) but offered complete transparency, allowing human operators to understand exactly which historical case motivated the diagnostic decision.
