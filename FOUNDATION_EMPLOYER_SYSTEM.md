# Foundation Employer System

## Overview
The employer system has been successfully replaced with a Foundation-based system that uses Class A, Class B, Security, Medical, Science, Engineering, Supply, Service, MTF, and Administrative personnel categories.

## 🎯 **New Foundation Employers**

### **Class-Based Employers**
- **`/datum/employer/foundation_class_a`** - Foundation Class A Personnel
  - Highest level of Foundation personnel
  - Access to all areas and information
  - O5 Council members, Site Directors, high-ranking officials

- **`/datum/employer/foundation_class_b`** - Foundation Class B Personnel
  - Senior Foundation personnel with extensive access
  - Research Directors, Chief Medical Officers, Chief Engineers, department heads

- **`/datum/employer/foundation_class_c`** - Foundation Class C Personnel
  - Standard Foundation personnel with moderate access
  - Researchers, medical staff, engineers, security personnel, operational staff

- **`/datum/employer/foundation_class_d`** - Foundation Class D Personnel
  - Expendable personnel for testing and containment procedures
  - Death row inmates or other expendable individuals

### **Department-Based Employers**
- **`/datum/employer/foundation_security`** - Foundation Security Personnel
  - Guards, MTF operatives, security-related personnel
  - Responsible for maintaining order and protecting Foundation assets

- **`/datum/employer/foundation_medical`** - Foundation Medical Personnel
  - Doctors, nurses, researchers, medical professionals
  - Responsible for health and well-being of Foundation staff and subjects

- **`/datum/employer/foundation_science`** - Foundation Science Personnel
  - Researchers, lab technicians, scientific staff
  - Responsible for research, analysis, and understanding of anomalous objects

- **`/datum/employer/foundation_engineering`** - Foundation Engineering Personnel
  - Engineers, technicians, technical staff
  - Responsible for maintaining and operating Foundation facilities and equipment

- **`/datum/employer/foundation_supply`** - Foundation Supply Personnel
  - Quartermasters, cargo technicians, supply-related staff
  - Responsible for managing resources, logistics, and procurement

- **`/datum/employer/foundation_service`** - Foundation Service Personnel
  - Janitors, cooks, service staff
  - Responsible for maintaining daily operations and quality of life

- **`/datum/employer/foundation_mtf`** - Mobile Task Force Personnel
  - Specialized personnel organized into Mobile Task Forces
  - Highly trained and equipped for various operational scenarios

- **`/datum/employer/foundation_admin`** - Foundation Administrative Personnel
  - Clerks, assistants, administrative staff
  - Responsible for managing records, communications, and bureaucratic functions

## 🔄 **Migration Summary**

### **Foundation-19 Jobs Updated**
- **Command Jobs**: All updated to use appropriate Foundation employers
  - Site Director, O5 Representative → `foundation_class_a`
  - Guard Commander → `foundation_security`
  - Research Director → `foundation_science`
  - Chief Medical Officer → `foundation_medical`
  - Chief Engineer → `foundation_engineering`

- **Security Jobs**: All updated to use `foundation_security`
  - LCZ/HCZ/EZ Zone Commanders
  - LCZ/HCZ/EZ Guards
  - MTF Commander and Operatives
  - Warden, Detective

- **Medical Jobs**: All updated to use `foundation_medical`
  - Medical Doctor, Surgeon, Paramedic
  - Chemist, Virologist, Psychiatrist
  - Medical Intern, Coroner

- **Science Jobs**: All updated to use `foundation_science`
  - Senior Researcher, Researcher
  - Research Associate, Lab Technician

- **Engineering Jobs**: All updated to use `foundation_engineering`
  - Station Engineer, Atmospheric Technician
  - Chief Engineer

- **Supply Jobs**: All updated to use `foundation_supply`
  - Quartermaster, Cargo Technician
  - Shaft Miner

- **Service Jobs**: All updated to use `foundation_service`
  - Bartender, Cook, Janitor
  - Botanist, Chaplain, Clown
  - Curator

- **D-Class Jobs**: All updated to use `foundation_class_d`
  - All D-Class positions

### **Existing Jobs Updated**
- **Security Jobs**: Updated to use `foundation_security`
  - Security Officer, Warden, Head of Security
  - Detective

- **Medical Jobs**: Updated to use `foundation_medical`
  - Virologist, Paramedic, Chemist
  - Psychologist, Acolyte, Augur

- **Engineering Jobs**: Updated to use `foundation_engineering`
  - Station Engineer, Atmospheric Technician
  - Chief Engineer

- **Supply Jobs**: Updated to use `foundation_supply`
  - Quartermaster, Cargo Technician
  - Shaft Miner

- **Service Jobs**: Updated to use `foundation_service`
  - Bartender, Cook, Janitor
  - Botanist, Chaplain, Clown
  - Curator

- **Administrative Jobs**: Updated to use `foundation_admin`
  - Lawyer

- **Management Jobs**: Updated to use appropriate Foundation classes
  - Captain → `foundation_class_a`
  - Head of Personnel → `foundation_class_b`
  - Bureaucrat → `foundation_admin`
  - Security Consultant → `foundation_security`

- **General Jobs**: Updated to use `foundation_class_c`
  - Assistant (simplified from multiple employers)

## 🎯 **Benefits of the New System**

### **Thematic Consistency**
- All jobs now use Foundation-based employers
- Maintains SCP Foundation lore and atmosphere
- Clear hierarchy and access levels

### **Organizational Clarity**
- Class-based system provides clear progression paths
- Department-based employers align with job functions
- Easier to understand job relationships and access levels

### **Gameplay Benefits**
- More immersive SCP Foundation experience
- Clearer role definitions and responsibilities
- Better integration with the persistent progression system

### **Technical Benefits**
- Simplified employer system
- Consistent naming conventions
- Easier to maintain and extend

## 🔧 **Legacy Compatibility**

### **Preserved Legacy Employers**
The following legacy employers are still defined for compatibility but are no longer used:
- `/datum/employer/government`
- `/datum/employer/daedalus`
- `/datum/employer/mars_exec`
- `/datum/employer/aether`
- `/datum/employer/hermes`
- `/datum/employer/none`

### **Migration Notes**
- All existing jobs have been successfully migrated
- No breaking changes to job functionality
- Employer system remains fully functional
- Compilation successful with 0 errors and 0 warnings

## 🚀 **Future Enhancements**

### **Potential Additions**
- **MTF-Specific Employers**: Different MTF units could have their own employers
- **Site-Specific Employers**: Different Foundation sites could have unique employers
- **Specialized Employers**: For unique roles like Ethics Committee, O5 Council, etc.

### **Integration Opportunities**
- **Persistent Progression**: Employers could affect experience gain and progression
- **Access Control**: Employers could determine access levels and permissions
- **Roleplay Elements**: Employers could provide unique roleplay opportunities

---

This Foundation employer system provides a solid foundation for the SCP-themed game while maintaining all existing functionality and improving thematic consistency.
