
import random

# ---------- SYSTEM ----------
def rand_int(a, b):
    return random.randint(a, b)

def generate_system():
    true_sol = [rand_int(-5, 5) for _ in range(3)]
    A = []
    B = []
    for _ in range(3):
        row = [rand_int(1, 9) for _ in range(3)]
        A.append(row)
        B.append(sum(row[i] * true_sol[i] for i in range(3)))
    return A, B, true_sol

# ---------- FITNESS ----------
def fitness(ind, A, B):
    err = sum(abs(sum(A[i][j]*ind[j] for j in range(3)) - B[i]) for i in range(3))
    return 1 / (1 + err)

# ---------- GA OPERATORS ----------
def tournament(pop, A, B):
    a = random.choice(pop)
    b = random.choice(pop)
    return a if fitness(a, A, B) > fitness(b, A, B) else b

def crossover(a, b):
    return [(a[i] + b[i]) / 2 for i in range(3)]

def mutate(ind, rate, amp):
    return [v + (random.uniform(-amp, amp) if random.random() < rate else 0) for v in ind]

# ---------- GA LOOP ----------
def genetic_algorithm(pop_size=400, generations=1000, mut_rate=0.3, mut_amp=1.0):
    A, B, true_sol = generate_system()
    print("System of equations:")
    for i in range(3):
        print(f"{A[i][0]}x + {A[i][1]}y + {A[i][2]}z = {B[i]}")
    print(f"Exact solution: x={true_sol[0]}, y={true_sol[1]}, z={true_sol[2]}\n")

    # initialize population
    pop = [[rand_int(-10, 10) for _ in range(3)] for _ in range(pop_size)]

    history = []
    for gen in range(generations):
        pop.sort(key=lambda ind: fitness(ind, A, B), reverse=True)
        best = pop[0]
        history.append(fitness(best, A, B))

        if gen % 50 == 0 or gen == generations - 1:
            print(f"Generation {gen}, Fitness: {fitness(best, A, B):.6f}, Best: x={best[0]:.4f}, y={best[1]:.4f}, z={best[2]:.4f}")

        next_gen = [best]  # elitism: keep best
        while len(next_gen) < pop_size:
            parent1 = tournament(pop, A, B)
            parent2 = tournament(pop, A, B)
            child = crossover(parent1, parent2)
            child = mutate(child, mut_rate, mut_amp)
            next_gen.append(child)
        pop = next_gen

    print("\nFinal best solution:")
    best = pop[0]
    print(f"x ≈ {best[0]:.4f}, y ≈ {best[1]:.4f}, z ≈ {best[2]:.4f}")
    print(f"Fitness: {fitness(best, A, B):.6f}")

# ---------- RUN ----------
if __name__ == "__main__":
    genetic_algorithm()