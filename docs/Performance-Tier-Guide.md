# Performance Tier Guide - Student Version

**Course:** MC3113 Mechatronic Systems Design  
**Institution:** General Sir John Kotelawala Defence University  
**Academic Year:** 2025/26  
**Version:** Student-v1.0

***

## Overview

Your line-follower controller will be assessed across **three performance tiers**, reflecting increasing levels of engineering maturity and system optimization. This guide helps you understand what each tier represents and how to structure your development process.

***

## Performance Tier Framework

### 🥉 Functional Performance Tier

**What it demonstrates:**
- All requirements are **met** with documented evidence
- Controller performs reliably across all three scenarios
- Systematic design process with clear traceability
- Functional safety considerations implemented

**Engineering characteristics:**
- Well-tuned classical control (P, PI, or PID)
- Reactive safety responses (e.g., obstacle detection → avoidance)
- Documented requirements-to-verification mapping
- Clear interface control documentation

**Typical development timeline:**
- Weeks 5-9: Requirements analysis, initial implementation
- Weeks 9-11: Systematic tuning and verification
- Week 12: Documentation and evidence package

**Key learning outcomes achieved:**
- Requirements-driven design
- Systematic V&V methodology
- MBSE traceability practices
- Functional safety awareness

***

### 🥈 Optimized Performance Tier

**What it demonstrates:**
- Requirements are **exceeded** through advanced techniques
- Performance optimization beyond basic compliance
- Predictive or adaptive control strategies
- Design trade-off analysis documented

**Engineering characteristics:**
- Advanced control strategies (feedforward, gain scheduling, or observers)
- Proactive safety approaches (prediction, early detection)
- Multi-objective optimization (time vs. energy, safety vs. speed)
- Sensitivity analysis and robustness evaluation

**Typical development timeline:**
- Weeks 5-7: Functional baseline established
- Weeks 8-10: Performance optimization and advanced techniques
- Weeks 11-12: Trade-off analysis and comparative evaluation

**Key learning outcomes achieved:**
- Performance optimization techniques
- Control system design trade-offs
- Predictive system behavior
- Comparative analysis skills

***

### 🥇 Excellent Performance Tier

**What it demonstrates:**
- Near-optimal performance across multiple metrics
- Research-grade implementation quality
- Novel approaches or sophisticated algorithms
- Comprehensive engineering analysis

**Engineering characteristics:**
- Optimal or model-based control (LQR, MPC, Kalman filtering)
- Integrated fault detection and diagnosis
- Formal verification or statistical performance guarantees
- Publication-quality documentation

**Typical development timeline:**
- Weeks 5-6: Rapid functional baseline
- Weeks 7-10: Advanced algorithm development and validation
- Weeks 11-12: Formal analysis, optimization, and comprehensive reporting

**Key learning outcomes achieved:**
- Advanced control theory application
- System modeling and identification
- Research methodology
- Professional engineering communication

***

## Development Pathway Guidance

### Stage 1: Requirements Understanding (Weeks 3-5)

**All tiers begin here:**
1. Study the project brief and requirements thoroughly
2. Understand the interface control document (ICD)
3. Map requirements to scenarios (S1, S2, S3)
4. Identify measurable success criteria
5. Plan your verification approach

**Deliverables:**
- Completed RTM template (initial version)
- ICD understanding demonstration
- Test plan outline

***

### Stage 2: Baseline Implementation (Weeks 5-7)

**Focus: Get something working**

**For Functional Tier (minimum viable):**
- Implement simple proportional (P) controller
- Achieve basic line following in S1
- Document initial results and identify issues
- Systematic gain tuning process

**For Optimized/Excellent Tiers (establish foundation):**
- Implement PI or PID controller
- Achieve stable S1 performance quickly
- Begin scenario-specific behavior analysis
- Identify performance bottlenecks early

**Checkpoint (Week 7 - PDR):**
- S1 functional performance demonstrated
- Controller structure defined
- Initial metrics documented
- Path to higher tiers identified (if pursuing)

***

### Stage 3: Scenario Completion (Weeks 7-9)

**Focus: All scenarios functional**

**For Functional Tier:**
- Extend controller to handle S2 (obstacle avoidance)
- Implement S3 fault handling (speed cap, degraded operation)
- Verify requirements met with documented evidence
- Tune parameters for reliability

**For Optimized Tier:**
- Implement predictive obstacle avoidance strategies
- Optimize S1 tracking performance
- Develop adaptive fault response for S3
- Begin comparative analysis (baseline vs. optimized)

**For Excellent Tier:**
- Implement advanced algorithms (feedforward, observers)
- Achieve near-zero tracking error in S1
- Perfect obstacle avoidance in S2
- Comprehensive S3 fault tolerance
- Begin formal performance analysis

**Checkpoint (Week 9 - CDR):**
- All three scenarios operational
- Requirements verification evidence collected
- Performance metrics documented
- Design rationale clearly articulated

***

### Stage 4: Optimization & Documentation (Weeks 9-12)

**Focus: Refinement and evidence**

**All tiers:**
- Complete RTM with full traceability
- Generate verification report with test logs
- Prepare performance analysis plots
- Document design iterations and decisions
- Map to relevant standards (VDI 2206, ISO 26262)

**Additional for Optimized/Excellent Tiers:**
- Comparative performance analysis
- Trade-off studies (e.g., energy vs. time)
- Sensitivity analysis (robustness to parameter changes)
- Design space exploration documentation

***

## Key Performance Dimensions

Your controller will be evaluated across multiple dimensions. Strive for **balanced performance** rather than optimizing a single metric.

### 1. Tracking Accuracy (S1)
**Measured by:** Integral Absolute Error (IAE)

**Engineering considerations:**
- Proportional gain affects responsiveness
- Integral action eliminates steady-state error
- Derivative term improves damping
- Saturation limits affect achievable performance

**Optimization hints:**
- Consider sensor noise and control saturation
- Model-based feedforward can reduce tracking error
- Gain scheduling adapts to different operating conditions

***

### 2. Time Efficiency (S1, S2, S3)
**Measured by:** Completion time

**Engineering considerations:**
- Higher speed increases disturbance sensitivity
- Energy efficiency trade-off with speed
- Safety constraints limit maximum velocity

**Optimization hints:**
- Adaptive speed based on tracking confidence
- Optimal velocity profile (fast on straights, slow on curves)
- Predictive deceleration before known disturbances

***

### 3. Energy Efficiency (S1)
**Measured by:** Cumulative motor energy consumption

**Engineering considerations:**
- Aggressive control uses more energy
- Smooth commands reduce energy waste
- Speed selection affects energy budget

**Optimization hints:**
- Minimize unnecessary oscillations
- Use minimum control effort for stability
- Trade-off: slower movement = less energy but longer time

***

### 4. Safety Performance (S2, S3)
**Measured by:** Obstacle contacts, line loss events, speed compliance

**Engineering considerations:**
- Reactive vs. predictive safety strategies
- Safe degraded operation during faults
- Verification of safety constraints

**Optimization hints:**
- Predictive obstacle avoidance (anticipate detection)
- Adaptive speed reduction based on uncertainty
- Formal safety argument (ISO 26262 approach)

***

## Standards and Traceability

### Required Documentation Elements

**All tiers must demonstrate:**

1. **Requirements Traceability Matrix (RTM)**
   - Link each requirement to implementation
   - Map implementation to verification test
   - Document verification results with evidence (CSV logs, plots)

2. **Interface Control Document (ICD)**
   - Clearly define controller inputs/outputs
   - Document data types, ranges, and units
   - Specify timing and sample rates

3. **Verification Report**
   - Test methodology description
   - Test results summary (pass/fail with evidence)
   - Analysis of failed requirements (if any)
   - Iteration history (what you tried and why)

4. **Standards Mapping**
   - VDI 2206:2021 (V-Model compliance)
   - ISO 26262:2018 (safety-critical elements)
   - ISO 14040/44:2006 (if LCA performed - optional)

***

## Common Questions

### Q: "How do I know which tier I'm aiming for?"

**A:** Start by targeting the Functional tier (all requirements met). Once you achieve this baseline:
- If you have 2+ weeks remaining → attempt Optimized tier techniques
- If you have 4+ weeks remaining → consider Excellent tier approaches
- **Never sacrifice functional completeness for partial optimization**

### Q: "Can I use MATLAB toolbox functions (e.g., `lqr`, `kalman`)?"

**A:** Yes, but you must **understand and document** what the function does:
- Derive the equations it implements
- Explain parameter selection rationale
- Demonstrate understanding through design trade-off analysis

Simply calling a black-box function without explanation does not demonstrate learning.

### Q: "My controller meets requirements in S1 but fails S2. What tier am I?"

**A:** Requirements are pass/fail boundaries. **All scenarios must pass** for any tier:
- If any scenario fails requirements → Not yet Functional tier
- Focus on achieving reliable performance across all three scenarios first
- Then optimize individual scenario performance

### Q: "Should I optimize for IAE or completion time?"

**A:** Both matter, but the **requirements define minimum acceptable performance**:
- First, meet all requirements (Functional tier baseline)
- Then, optimize based on **your design philosophy** (document trade-offs)
- Example: "Prioritized energy efficiency over speed because [rationale]"

Your design decisions should reflect **engineering judgment**, not arbitrary choices.

***

## Design Iteration Best Practices

### Document Your Journey

**Keep a design log:**
```
Run ID: Test_S1_v3
Date: 2026-02-15
Controller: PID with Kp=2.5, Ki=0.5, Kd=0.3
Results: IAE = 1.8 m·s, Time = 85s
Observations: Overshoot reduced but completion time increased
Next iteration: Try Kp=3.0 to increase responsiveness
```

This log becomes evidence of **systematic engineering** in your documentation.

***

### Progressive Tuning Strategy

**Week 5-6: Proportional (P) only**
- Get basic line following working
- Observe steady-state error
- Document why P-only is insufficient

**Week 7-8: Add Integral (I) term**
- Eliminate steady-state error
- Observe potential instability or windup
- Implement anti-windup if needed

**Week 8-9: Add Derivative (D) term**
- Improve damping and transient response
- Reduce overshoot
- Balance all three gains

**Week 9+ (if pursuing Optimized/Excellent):**
- Feedforward compensation
- Gain scheduling or adaptive control
- Observer-based state estimation

***

## Assessment Philosophy

Your work will be evaluated on:

### Technical Performance (Quality of Results)
- Do all scenarios meet requirements?
- How much margin exists beyond minimum thresholds?
- Are advanced techniques implemented correctly?

### Engineering Process (How You Got There)
- Is your design process systematic and traceable?
- Have you documented iterations and design decisions?
- Does your RTM show clear requirements flow-down?

### Professional Communication (How You Present It)
- Is your documentation clear, organized, and professional?
- Do your plots and tables effectively communicate results?
- Have you followed standards and best practices?

### Design Maturity (Depth of Understanding)
- Can you explain **why** your controller works?
- Have you analyzed trade-offs and limitations?
- Do you understand the control theory behind your choices?

***

## Resources and Support

### Recommended Reading

**Classical Control:**
- Nise, "Control Systems Engineering" (PID tuning, root locus)
- Ogata, "Modern Control Engineering" (state-space, observers)

**MBSE & Standards:**
- VDI 2206:2021 (available in library)
- ISO 26262 Part 3 (functional safety concepts)
- Course lecture materials (Weeks 3-7)

### Getting Help

**Office Hours:** See course Moodle for schedule  
**GitHub Repository:** [https://github.com/asithakal/MC3113-LineFollower-AY25](https://github.com/asithakal/MC3113-LineFollower-AY25)  
**Email:** asitha@uom.lk (response within 48 hours)

**What to bring:**
- Your latest test results (CSV logs)
- Specific error messages or unexpected behavior
- What you've already tried

***

## Final Advice

### Do's ✅
- Start simple and build incrementally
- Document every design decision
- Test frequently with all three scenarios
- Keep backups of working versions
- Ask for help when stuck for more than 2 hours

### Don'ts ❌
- Don't wait until Week 11 to start S2/S3
- Don't copy code without understanding it
- Don't optimize prematurely (get it working first)
- Don't ignore requirements you find "boring"
- Don't skip documentation until the end

***

## Remember

**The tier you achieve reflects your engineering maturity, not just your coding skills.**

A well-documented Functional tier submission with clear traceability and systematic design is more valuable than a poorly-explained "excellent" performance with no design rationale.

**Focus on the process, and the results will follow.**

***

**Good luck with your design!** 🚀

***

**Questions about this guide?** Bring them to the lecture or email.
