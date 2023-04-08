# basic Adaptive Large Neighborhood Search for MiniZinc
# made by Mateusz Ślayński for the teaching purposes
from __future__ import annotations
from dataclasses import dataclass
import math
import random
from naive_adaptive_lns import CPSolution, CPSolver, NaiveAdaptiveLNS


@dataclass
class TSPSolution(CPSolution):
    route: list[int]
    total_distance: int
    
    @property
    def assignment(self) -> list[int]:
        return self.route 

    @property
    def objective(self) -> int:
        return self.total_distance    

    def should_minimize(self) -> bool:
        return True
    
    def relax(self, ratio: float) -> list[int]:
        '''
        This function should relax random {rate}% of the solution.
        Solution is just a list of numbers.
        We just have to create a new list where random {rate}% of the numbers are zeros!
        '''
        fixed_route = self.route.copy()
        n_relax = math.floor(ratio * len(fixed_route))+1
        for i in range(n_relax):
            idx = random.randint(1, len(fixed_route) - 1)
            fixed_route[idx] = 0
        # TODO: set some values to zeros as in the docstring
        #  tip. random and math modules may be useful, try to not import anything else
        return fixed_route


class TSPSolver(CPSolver[TSPSolution]):

    def initial_solution(self) -> TSPSolution:
        '''
        Finds the initial solution
        Returns a new TSP Solution
        '''
        res = self._initial_instance.solve()
        return TSPSolution(res["route"], res["total_distance"])

    def improve_partial_assignment(self, assignment: list[int]) -> TSPSolution:
        '''
        This function improves the given solution.
        '''
        # the branch method creates a new "copy of the model instance"
        with self._improve_instance.branch() as opt:
            # then we set the initial_route
            opt["initial_route"] = assignment
            res = opt.solve()
            return TSPSolution(res["route"], res.objective)


if __name__ == "__main__":
    # change path to solve different instance
    problem_path = "data/eil51.dzn"
    init_model = "tsp_init.mzn"
    improve_model = "tsp_improve.mzn"

    solver = TSPSolver(problem_path, init_model, improve_model)
    lns = NaiveAdaptiveLNS(solver)
    lns.solve()
