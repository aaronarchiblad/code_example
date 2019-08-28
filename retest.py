import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from scipy import stats
import seaborn as sns
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, roc_curve, auc, roc_auc_score, confusion_matrix, precision_recall_curve
from sklearn.linear_model import LogisticRegression

# recode string to numerical data
D = pd.read_csv("/Users/aaronpr_us/Documents/Academics/Job/Wegene/Retest_Project/retest_result.csv", header=0, sep=',')
D.head()


D.info()

D.describe()


# calculate the percentage of missing data for each rows, delete features dna_qubit_first and dna_qubit since there are too many missing rows
round(D.isna().sum()/D.isna().count()*100,2).sort_values(ascending=False)


# dna_extraction_method_first has only one value, so take this down
D = D.drop(['dna_qubit', 'dna_qubit_first'], axis=1)
cat = D.select_dtypes(include='object')
value = pd.Series([cat.iloc[:, i].unique().tolist() for i in range(cat.shape[1])])
column_name = pd.Series(cat.columns.tolist())
column_value = pd.concat([column_name, value], axis=1, keys=['column_name', 'column_value'])
column_value

D = D.drop(['dna_extraction_method_first'], axis=1)

# remove all the rows without labels
D = D.dropna(subset=['result'])
D.head()


# combine two types of failure into one
D.loc[D['result'] == "重测上机成功", 'result'] = 'success'
D.loc[((D['result'] == "重测DNA失败") | (D['result'] == "重测上机失败")), 'result'] = 'fail'
D.head()

pd.crosstab(D['result'], D['dna_extraction_method'], margins=True)


round(D.isna().sum()/D.isna().count()*100,2).sort_values(ascending=False)


# Since the rest of missing value are from the same rows, so I just drop those 3 rows
D = D.dropna(subset=['gc50', 'gc10', 'logr', 'callrate', 'qc_callrate'])

# replace missing value from dna_enzyme with inverse lognormal distribution
enz = np.log(D['dna_enzyme'].dropna())
test = (-np.random.lognormal(0.07, 1, size=1000) + 5)


fig = plt.plot(figsize=(10, 4))
fig = sns.distplot(test, hist=True, kde=True, bins=30, label='lognormal')
fig = sns.distplot(enz, hist=True, kde=True, bins=30, label='enzyme')
fig.legend()

size = sum(D['dna_enzyme'].isna())
value = np.abs(-np.random.lognormal(0.07, 1, size=size) + 5)
D.loc[D['dna_enzyme'].isna(), 'dna_enzyme'] = np.exp(value)
round(D.isna().sum()/D.isna().count()*100,2).sort_values(ascending=False)

D.head()


# Convert categorical variables into numeric variables
le = LabelEncoder()
col_name = ['result', 'extraction_process', 'dna_extraction_automation', 'dna_extraction_method', 'dna_extraction_reagent', 'dna_pcr_result', 'dna_extraction_reagent_first', 'dna_pcr_result_first']
for name in col_name:
    le.fit(D[name])
    encoded_value = le.transform(D[name])
    D[name] = encoded_value

X.head()

X = D.drop(['result', 'dna_extraction_automation'], axis=1)
y = D['result']
def main():
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    rf = RandomForestClassifier(n_estimators=50, max_depth=3)
    rf.fit(X_train, y_train)
    y_pred_rf = rf.predict(X_test)
    rf_acc = accuracy_score(y_pred_rf, y_test)
    return rf_acc, boost_acc

rf_acc = []
boost_acc = []
for i in range(100):
    a, b = main()
    rf_acc.append(a)
    boost_acc.append(b)
np.mean(rf_acc)
np.mean(boost_acc)

d = D[['result', 'qc_callrate']]
sns.boxplot(data=d, x='result', y='qc_callrate')

pd.crosstab(index=D['result'], columns=D['dna_pcr_result_first'], margins=True)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
rf = RandomForestClassifier(n_estimators=50, max_depth=3)
rf.fit(X_train, y_train)
y_pred_rf = rf.predict(X_test)
rf_acc = accuracy_score(y_pred_rf, y_test)
rf_acc
y_pred_rf
rf.feature_importances_
X_train.columns
np.array(y_test)

p = rf.predict_proba(X_test)[:,1]
fpr, tpr, thresholds = roc_curve(y_test, p)
plt.plot([0, 1], [0, 1], linestyle='--')
plt.plot(fpr, tpr, marker='.')
plt.show()
auc = roc_auc_score(y_test, p)
auc

X_cts = D[['dna_enzyme', 'qc_callrate', 'callrate', 'logr', 'gc10', 'gc50', 'dna_enzyme_first', 'rlane', 'clane', 'dna_pcr_result', 'dna_pcr_result_first']]
X_cts_train, X_cts_test, y_cts_train, y_cts_test = train_test_split(X_cts, y, test_size=0.2)
logit_reg = LogisticRegression(solver='liblinear', penalty='l1')
logit_reg.fit(X_cts_train, y_cts_train)
y_pred = logit_reg.predict(X_cts_test)
acc = accuracy_score(y_pred, y_cts_test)
logit_reg.coef_
acc

%matplotlib inline
cm = confusion_matrix(y_true=y_test, y_pred=y_pred_rf)
cm = cm.astype('float')/cm.sum(axis=1).reshape(2,1)
label = ['success', 'fail']
fig, ax = plt.subplots()
im = ax.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
ax.figure.colorbar(im, ax=ax)
ax.set(xticks=np.arange(cm.shape[1]), yticks=np.arange(cm.shape[0]), xticklabels=label, yticklabels=label, xlabel='Predicted Label', ylabel='True Label')
plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
             rotation_mode="anchor")
             # rotate the tick labels and set their alignment.

for i in range(cm.shape[0]):
    for j in range(cm.shape[1]):
        ax.text(j,i, format(cm[i,j], '.2f'), ha='center', va='center')


cm = confusion_matrix(y_true=y_test, y_pred=y_pred_rf)
cm
precision = 21/(21+18)
recall = 21/(21+13)
F1 = 2*(precision * recall)/precision*recall
precision
recall
F1

X.head()

sns.boxplot(data=D[['callrate', 'result']], x='result', y='callrate')

D.loc[(D['qc_callrate'] <=90) & (D['result']==0)].shape

fig = plt.plot(figsize=[7,4])
fig = sns.distplot(D.loc[D['result']==1,'callrate'], hist=True, bins=10, norm_hist=True, label='success')
fig = sns.distplot(D.loc[D['result']==0,'callrate'], hist=True, bins=10, norm_hist=True, label='fail')
fig.legend()

fig = plt.plot(figsize=[7,4])
fig = sns.distplot(D.loc[D['result']==1,'qc_callrate'], hist=True, bins=10, norm_hist=True, label='success')
fig = sns.distplot(D.loc[D['result']==0,'qc_callrate'], hist=True, bins=10, norm_hist=True, label='fail')
fig.legend()
