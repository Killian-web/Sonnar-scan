def stages_cancer(**kwargs):
    sum_level = 0
    print(kwargs)

    for value in kwargs.values():
        sum_level += value

    return f" The sum of the stages of cancer is : {sum_level}"


print(stages_cancer(a=2, b=5, c=8))