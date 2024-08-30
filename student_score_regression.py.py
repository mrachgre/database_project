import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OrdinalEncoder, OneHotEncoder, LabelEncoder
from sklearn.compose import ColumnTransformer
from ydata_profiling import ProfileReport
from sklearn.linear_model import LinearRegression
from sklearn.svm import SVR
from sklearn.metrics import r2_score
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import GridSearchCV
from lazypredict.Supervised import LazyClassifier, LazyRegressor
data = pd.read_csv("StudentScore.xls")
# split data axis = 0 and axis = 1
# profile = ProfileReport(data, title = 'report about student_score', explorative= True)
# profile.to_file('student.html')
target = 'math score'
x = data.drop(['math score'], axis = 1)
y = data[target]
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state= 299299)

# Preprocessing

# for numeric
num_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='median')),
    ('Scaler', StandardScaler())
])
# for ordinal
education_values = ["some high school", "high school", 'some college', "associate's degree", "bachelor's degree", "master's degree"]
gender = x_train['gender'].unique()
lunch = x_train['lunch'].unique()
test_pre = x_train['test preparation course'].unique()
ord_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ("ordinal", OrdinalEncoder(categories=[education_values, gender, lunch, test_pre ]))
])

# for nominal
no_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('one_hot', OneHotEncoder(sparse_output = False, handle_unknown='ignore'))
])

# transform all the column

preprocessor = ColumnTransformer(transformers=[
    ("num_features", num_transformer, ['writing score', 'reading score']),
    ("ord_features", ord_transformer, ['parental level of education', 'gender', 'lunch', 'test preparation course']),
    ("no_features", no_transformer, ['race/ethnicity'])
])


# reg = Pipeline(steps=[
#     ("preprocessing", preprocessor),
#     ('model', RandomForestRegressor(random_state=100))
# ])

params = {
    'model__n_estimators' : [50, 100, 200],
    'model__criterion' : ['squared_error', 'absolute_error', 'poisson'],
    'preprocessing__no_features__one_hot__sparse_output' :[False, True]
}

reg = LazyRegressor(verbose=0,ignore_warnings=False, custom_metric=None )
models,predictions = reg.fit(x_train, x_test, y_train, y_test)



