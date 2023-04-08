from abc import ABC, abstractmethod, abstractproperty
import time
from typing import Generic, TypeVar
from typing_extensions import Self
from minizinc import Instance, Model, Solver


class CPSolution(ABC):

    @abstractproperty
    def objective(self) -> int:
        """objective value"""
    
    @abstractproperty
    def assignment(self) -> list[int]:
        """assignment (very naive — just list of ints)"""
        
    @abstractproperty
    def should_minimize(self) -> bool:
        """returns True, if we minimize objective, otherwise False"""

    @abstractmethod
    def relax(self, ratio: float) -> list[int]:
        """return assignment with {ratio} of variables relaxed"""

    def is_better_than(self, other: Self) -> bool:
        if self.should_minimize:
            return self.objective < other.objective 
        return self.objective > other.objective


S = TypeVar("S", bound=CPSolution)
class CPSolver(ABC, Generic[S]):
    _initial_instance: Model 
    _improve_instance: Model 


    def __init__(self, 
                problem_path: str, 
                init_model_path: str, 
                improve_model_path: str,
                solver_name: str = "gecode") -> None:
        super().__init__()

        # load minizinc solver
        minizinc_solver = Solver.lookup(solver_name)

        # load model finding the initial solution
        initial_model = Model()
        initial_model.add_file(init_model_path)
        initial_model.add_file(problem_path)

        # create model instance with the given solver
        self._initial_instance = Instance(minizinc_solver, initial_model)

        # load model improving the solution
        improve_model = Model()
        improve_model.add_file(improve_model_path)
        improve_model.add_file(problem_path)

        # create model instance with the given solver
        self._improve_instance = Instance(minizinc_solver, improve_model)

    @abstractmethod
    def initial_solution(self) -> S:
        """finds initial feasible solution and its objective value"""

    @abstractmethod
    def improve_partial_assignment(self, assignment: list[int]) -> S:
        """improves the given solution using specified relax ratio"""

    
class NaiveAdaptiveLNS:
    solver: CPSolver[S]
    initial_zeroing_ratio: float 
    adaption_rate: float 
    adaption_timelimit_in_sec: int

    def __init__(self, solver: CPSolver[S], 
                       initial_zeroing_ratio: float = 0.1,
                       adaption_rate: float = 0.05,
                       adaption_timelimit_in_sec: int = 10
                ) -> None:
        self.solver = solver 
        self.initial_zeroing_ratio = initial_zeroing_ratio
        self.adaption_rate = adaption_rate
        self.adaption_timelimit_in_sec = adaption_timelimit_in_sec

    def solve(self):
        zeroing_ratio = self.initial_zeroing_ratio

        # just to calculate how much time we spent on the optimization
        checkpoint = time.time()
        # we get the initial solution and mark it as the best
        best_solution = self.solver.initial_solution()

        # the LNS loop, so exciting
        while zeroing_ratio <= 1.0:
            # we relax the current solution to get a relaxed assignment
            partial_assignment = best_solution.relax(zeroing_ratio)
            # we try to optimize starting from partial assignment
            new_solution = self.solver.improve_partial_assignment(partial_assignment)

            # if it's better than the old one
            if new_solution.is_better_than(best_solution):
                checkpoint = time.time()
                # we reset the zeroing rate
                zeroing_ratio = self.initial_zeroing_ratio
                # we remember the best solution
                best_solution = new_solution
                # and print it
                print(f"objective = {best_solution.objective}")
                print(f"assignment = {best_solution.assignment}")
                print("-------------------------")

            # if the solver struggles we increase the zeroing rate :)
            if time.time() - checkpoint > self.adaption_timelimit_in_sec:
                checkpoint = time.time()
                zeroing_ratio += self.adaption_rate
                print(f"* changed zeroing rate to {zeroing_ratio}")