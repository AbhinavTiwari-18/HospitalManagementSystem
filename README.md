# 🏥 Hospital Management System (Salesforce)

A cloud-based **Hospital Management System** built on the **Salesforce Platform** to streamline hospital operations, patient management, appointment scheduling, billing, and medical record management.

This project leverages **Salesforce Apex, Lightning Web Components (LWC), Flows, SOQL, Experience Cloud, and Salesforce DX** to deliver a scalable and secure healthcare management solution.

---

## 🚀 Features

* 👨‍⚕️ Patient Registration & Management
* 📅 Doctor Appointment Scheduling
* 🩺 Doctor & Staff Management
* 🏥 Department and Hospital Management
* 🛏️ Room & Bed Allocation
* 💊 Treatment & Medical Records
* 🧾 Billing & Invoice Management
* 🔬 Lab Test Reports
* 🌐 Experience Cloud Patient Portal
* 🔒 Role-Based Access Control
* ⚡ Automation using Salesforce Flows & Apex

---

## 🛠️ Tech Stack

* **Salesforce DX**
* **Apex**
* **Lightning Web Components (LWC)**
* **SOQL & SOSL**
* **Salesforce Flows**
* **Experience Cloud**
* **Custom Objects**
* **Validation Rules**
* **Profiles & Permission Sets**
* **Git & GitHub**
* **Visual Studio Code**

---

## 📂 Project Structure

```text
HospitalManagementSystem/
│── force-app/
│   ├── main/
│   │   ├── default/
│   │   │   ├── classes/
│   │   │   ├── lwc/
│   │   │   ├── objects/
│   │   │   ├── flows/
│   │   │   ├── layouts/
│   │   │   ├── permissionsets/
│   │   │   └── triggers/
│── manifest/
│── scripts/
│── sfdx-project.json
└── README.md
```

---

## 📋 Custom Objects

* Hospital
* Department
* Employee (Doctor, Nurse, Receptionist, Admin)
* Patient
* Appointment
* Treatment
* Admission
* Room
* Bed
* Bill
* Bill Line Item
* Inventory
* Lab Report

---

## ⚙️ Key Functionalities

### Patient Management

* Register new patients
* Maintain patient profiles
* View treatment history

### Appointment Management

* Schedule appointments
* Prevent double booking
* Doctor availability management

### Billing System

* Generate bills automatically
* Manage bill line items
* Track payments

### Hospital Administration

* Manage doctors and staff
* Department management
* Room and bed allocation

### Patient Portal

* Book appointments
* View bills
* Access medical reports
* Track appointment history

---

## 🚀 Deployment

Clone the repository

```bash
git clone https://github.com/<your-username>/HospitalManagementSystem.git
```

Open the project

```bash
cd HospitalManagementSystem
code .
```

Authorize your Salesforce Org

```bash
sf org login web
```

Deploy the project

```bash
sf project deploy start
```

---

## 📌 Future Enhancements

* AI-powered appointment recommendations
* Doctor availability calendar
* Email & SMS notifications
* Payment Gateway Integration
* Mobile Application Integration
* Dashboard & Analytics
* REST API Integration
* Electronic Health Records (EHR)

---

## 👨‍💻 Author

**Abhinav Tiwari**

Salesforce Developer | Apex | LWC | Experience Cloud | Salesforce DX

---

## ⭐ Support

If you found this project helpful, consider giving it a **⭐ Star** on GitHub.
