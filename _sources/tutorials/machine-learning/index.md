# Machine Learning

<p class="acknowledgement">Written by Allan Leal (ETH Zurich) on Nov 16th, 2022</p>

Reaktoro implements machine learning accelerated solvers for chemical equilibrium and chemical kinetics computations. They are available through the solver classes {{SmartEquilibriumSolver}} and {{SmartKineticsSolver}}, whose usage is very similar to that of {{EquilibriumSolver}} and {{KineticsSolver}} for conventional equilibrium and kinetics computations, in which iterative algorithms are used and each iteration can be very expensive.

These smart solvers rely on the ***on-demand machine learning*** (ODML) algorithm first introduced in {cite:t}`Leal2017b`, then improved in {cite:t}`Leal2020` and finally extensively tested in {cite:t}`Kyas2022`. ODML enables these solvers to bypass all expensive iterative computations when equilibrium and/or kinetics calculations are to be performed with *inputs that are similar to previous ones*. When this is possible, a quick *first-order Taylor approximation* of the solution is computed (*the predicted solution*), instead of fully computing it iteratively (which can be very expensive for complex chemical systems). If the prediction is not accurate enough, the full calculation is performed, and *sensitivity derivatives* of the computed solution with respect to input conditions are determined next, using automatic differentiation (Reaktoro relies on the `autodiff` library for this - see [autodiff.github.io](https://autodiff.github.io)). And this is what constitutes the *on-demand learning operation* in the ODML algorithm!

ODML has several advantages over machine learning algorithms based on neural networks as detailed below (taken from {cite:t}`Leal2020`):

**Accuracy.** The use of sensitivity derivatives permits the behavior of a chemical system with multiple phases and species to be accurately predicted in the vicinity of a known chemical state, previously computed via chemical equilibrium and/or kinetics. Error control can be employed to estimate the actual accuracy of the predictions. It can respond, if necessary, with a rapid on-demand learning operation that will fully solve the equilibrium/kinetics problem and compute the associated sensitivity derivatives with the hope to be used for subsequent prediction tentatives. The proposed smart chemical equilibrium/kinetics algorithm, relying on ODML, avoids thus the acceptance of a predicted chemical state that potentially deviates too much from required equilibrium/kinetic conditions (e.g. mass action equilibrium conditions). Estimating these errors with artificial neural networks and interpolation-based algorithms is generally not possible, implying that these algorithms may accept predicted chemical states that violate both mass balance and mass action equations by an unacceptable margin of errors.

**Mass conservation.** Chemical equilibrium and kinetics calculations contain mass balance constraints for chemical elements and electric charge. The prediction of chemical states using first-order sensitivity derivatives is intrinsically mass conservative because mass balance equations are linear (mathematical demonstration in Appendix C of {cite}`Leal2020`). Achieving exact accuracy with artificial neural networks and surrogate models, however, is a nontrivial problem, either requiring special treatment and/or exhaustive training because these methods lack “understanding” of the inherent conservation laws of the problems being emulated. Deficient mass conservative capabilities can be more easily understood for regression models that are not exact interpolators, i.e., regression models that do not produce an exact output for an input that was previously used for its construction/training. The output, in this case, has to be mathematically exact, and not a sufficiently accurate approximation. These classes of regression models, therefore, do not honor the existing mass balance relationship between input and output data.

**No need for a priori training.** With fast on-demand learning operations, there is no need to artificially generate a large collection of input-output data for training before the simulation. This permits the deployment of a reactive transport simulation that wants to take advantage of machine learning accelerated chemical solvers in a more straightforward way, without concerns whether the trained input-output data has proper coverage for all possible chemical conditions that will arise during the simulation using fine resolution meshes and stricter time step lengths. With surrogate models and artificial neural networks, the produced regression models can only get more accurate the more it trains in advance, requiring a comprehensive dataset whose size is not known beforehand in most cases. This can, in turn, accidentally result in overfitting (or overtraining), a common condition in statistics and machine learning that impairs the predictive capacity of the regression model instead of enhancing it.

**Optimal and compact dataset.** Spontaneous learning, only needed occasionally during the reactive transport simulation to keep new predictions accurate enough, produces data that need to be recorded in a data structure. The sensitivity data obtained at the end of each full equilibrium/kinetics calculation is generally small compared to that needed by approximation methodologies based on interpolation or statistical training at high-dimension input space. For the latter cases, a dense cloud of points may be needed for accurate interpolation or learning (e.g. k-NN regression). Whereas for the on-demand machine learning approach, it suffices to store, for each learned chemical state, a matrix of sensitivity derivatives with roughly the number of rows and columns equal to the number of species and elements respectively. If temperature and pressure derivatives are also considered, then two more columns are appended.

**Reliability.** Throughout a reactive transport simulation, a sheer number of distinct chemical conditions/features may occur. In the majority of cases, these cannot be foreseen, especially when processes occur under different space/time scales. Performing these simulations using conventional chemical equilibrium/kinetics algorithms, rigorously tested for robustness, may have prohibitive computing costs in complicated scenarios. However, they have an undisputed advantage compared to most unconventional predictive algorithms so far mentioned here: they are reliable and they are our benchmark for any acceleration strategy. Because the smart chemical equilibrium/kinetics algorithm used in Reaktoro either performs a sufficiently accurate prediction or resorts to the conventional algorithm for the exact computation, it could be considered equally reliable. This is true as long as tolerance values for estimated errors are not overly relaxed. Therefore, a modeler using the smart equilibrium/kinetics algorithm accelerated with ODML can remain confident throughout the reactive transport simulation that any newly arising chemical condition and reactivity behavior from the millions to billions of equilibrium/kinetics problems will be met with either an accurate estimate or an exact solution.

Continue reading to learn more on how to use the solver classes {{SmartEquilibriumSolver}} and {{SmartKineticsSolver}} and how to take advantage of ODML for machine learning accelerated chemical equilibrium and kinetics calculations.

```{tableofcontents}
```