# -*- coding: utf-8 -*-
"""
Created on Mon Sep  3 23:40:19 2018

@author: Rudra Narayan Chand
"""
#Predicting the delay probabilities for GE Power Aviation Dataset

#import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
#import scipy
#import scipy.stats import chi2
import os
import seaborn as sns
from sklearn.utils import shuffle
get_ipython().run_line_magic('matplotlib', 'inline')
import warnings
warnings.filterwarnings('ignore')
pd.set_option('display.float_format', lambda x: '%.3f' % x)
##set working directories
os.chdir('give the path of file')
#import data
invoice=pd.read_csv('invoice_data.csv',encoding='ISO-8859-1')
invoice.columns
##########Feature Selection ,Preprocessing
#############################################################################
#selecting most significant columns
invoice_data=invoice[['invoice_number','invoice_date','invoice_due_date','invoice_close_date',
                      'acctd_amount_due_original','component_code','ordering_customer_name','ship_to_customer_city_name',
                      'segment','payment_term_name','risk_state_name']]

###    
invoice_data.dropna(subset=['segment'],inplace=True)
#convert date from string to date format
invoice_data.invoice_date=pd.to_datetime(invoice_data.invoice_date)
invoice_data.invoice_due_date=pd.to_datetime(invoice_data.invoice_due_date)
invoice_data.invoice_close_date=pd.to_datetime(invoice_data.invoice_close_date)
#Calculate number of delay days
invoice_data['past_due_day_count'] = invoice_data['invoice_close_date'] - invoice_data['invoice_due_date']
invoice_data.past_due_day_count=invoice_data.past_due_day_count.astype('timedelta64[D]')
invoice_data.past_due_day_count.fillna(invoice_data["past_due_day_count"].mean(), inplace=True)
##distribution
plt.hist(invoice_data["acctd_amount_due_original"],bins=20)
plt.show()
##
plt.hist(invoice_data["past_due_day_count"],bins=20)
plt.show()
###outliars remove
def drop_outliers(df, field_name):
    distance = 1.5 * (np.percentile(df[field_name], 75) - np.percentile(df[field_name], 25))
    df.drop(df[df[field_name] > distance + np.percentile(df[field_name], 75)].index, inplace=True)
    df.drop(df[df[field_name] < np.percentile(df[field_name], 25) - distance].index, inplace=True)
    
drop_outliers(invoice_data,"acctd_amount_due_original")
drop_outliers(invoice_data,"past_due_day_count")
#invoice_data.to_csv("submission.csv", index = False, sep=',')
##calculating delay status 
invoice_data['Delay_Status']=np.where(invoice_data['past_due_day_count'] > 0,1,0)
invoice_data['Delay_Status']=invoice_data['Delay_Status'].astype('category')
invoice_data=invoice_data[['acctd_amount_due_original','segment','component_code',
                           'ordering_customer_name','ship_to_customer_city_name',
                           'payment_term_name','risk_state_name','Delay_Status']]
#########################################################################################
invoice_data.info()
invoice_data['segment'].value_counts()
cleanup_nums = {"segment":     {"FLOW PARTS": 1, "CSA": 2,"CORE MAINTENANCE":3,
                                "NON-FUNCTIONS":4,"REPAIRS":5,"TOTAL ELC":6,
                                "PLACEHOLDER":7,"CORE":8,"PLANT ASSET MANAGEMENT":9,
                                "O&M ONLY":10,"FUNCTIONS":11,"LES":12,"REFURBISH":13,
                                "P&RS - TOTAL STEAM GEN REPAIRS":14,"RESOURCES":15,
                                "P&RS - TOTAL GAS REPAIRS":16,"MMP":17}}
invoice_data.replace(cleanup_nums, inplace=True)

invoice_data['payment_term_name'].value_counts()
invoice_data['payment_term_name']=invoice_data['payment_term_name'].astype('category')
invoice_data['payment_term_name']=invoice_data['payment_term_name'].cat.codes
invoice_data['ordering_customer_name'].value_counts()
cleanup1 = {"ordering_customer_name":     {"TENNESSEE VALLEY AUTHORITY": 1, 
                                           "INTERNATIONAL PAPER": 0}}
invoice_data.replace(cleanup1, inplace=True)
invoice_data['risk_state_name']=invoice_data['risk_state_name'].astype('category')
invoice_data['risk_state_name']=invoice_data['risk_state_name'].cat.codes
invoice_data['ship_to_customer_city_name'].value_counts()
invoice_data['ship_to_customer_city_name']=invoice_data['ship_to_customer_city_name'].astype('category')
invoice_data['ship_to_customer_city_name']=invoice_data['ship_to_customer_city_name'].cat.codes
#
invoice_data['risk_state_name']=invoice_data['risk_state_name'].astype('category')
invoice_data['segment']=invoice_data['segment'].astype('category')
invoice_data['payment_term_name']=invoice_data['payment_term_name'].astype('category')
invoice_data['ordering_customer_name']=invoice_data['ordering_customer_name'].astype('category')
invoice_data['ship_to_customer_city_name']=invoice_data['ship_to_customer_city_name'].astype('category')
#
invoice_data['component_code'].value_counts()
invoice_data['component_code']=invoice_data['component_code'].astype('category')
invoice_data['component_code']=invoice_data['component_code'].cat.codes
invoice_data.info()

##
X=invoice_data.iloc[:,0:7].values
y=invoice_data.iloc[:,7:8].values
###Boruta Feature selection
from sklearn.ensemble import RandomForestClassifier
from boruta import BorutaPy
rfc = RandomForestClassifier(n_estimators=200, n_jobs=4, class_weight='balanced', max_depth=6)
boruta_selector = BorutaPy(rfc, n_estimators='auto', verbose=2)
##start_time = timer(None)
boruta_selector.fit(X, y)
##timer(start_time)
## check selected features - first 5 features are selected
boruta_selector.support_
## check ranking of features
boruta_selector.ranking_
## call transform() on X to filter it down to selected features
X_filtered = boruta_selector.transform(X)
# Splitting the dataset into the Training set and Test set

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X_filtered, y, test_size = 0.20, random_state = 0)
# Feature Scaling
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
# Fitting Logistic Regression to the Training set
from sklearn.linear_model import LogisticRegression
classifier = LogisticRegression(random_state = 0)
classifier.fit(X_train, y_train)

# Predicting the Test set results
y_pred = classifier.predict(X_test)

# Making the Confusion Matrix
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_test, y_pred)
#Accuracy score
from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import roc_curve
accuracy_logistic=accuracy_score(y_test,y_pred)
#accuracy_logistic 0.6934753661784288
# recall score
# predict probabilities
probs = classifier.predict_proba(X_test)
# keep probabilities for the positive outcome only
probs = probs[:, 1]
# calculate AUC
auc = roc_auc_score(y_test, probs)
print('AUC: %.3f' % auc)
# calculate roc curve
fpr, tpr, thresholds = roc_curve(y_test, probs)
plt.plot([0, 1], [0, 1], linestyle='--')
# plot the roc curve for the model
plt.plot(fpr, tpr, marker='.')
# show the plot
plt.show()

##############################################################################
####Random Forest
from sklearn.ensemble import RandomForestClassifier
clf_rf = RandomForestClassifier(n_estimators=25, random_state=12)
clf_rf.fit(X_train, y_train)
# Make predictions
prediction_test = clf_rf.predict(X_test)
accuracy_rf=accuracy_score(y_test,prediction_test)
cm_rf=confusion_matrix(y_test,prediction_test)
# predict probabilities
probs_rf = clf_rf.predict_proba(X_test)
# keep probabilities for the positive outcome only
probs_rf = probs_rf[:, 1]
# calculate AUC
auc_rf = roc_auc_score(y_test, probs_rf)
print('AUC: %.3f' % auc_rf)
# calculate roc curve
fpr_rf, tpr_rf, thresholds_rf = roc_curve(y_test, probs_rf)
plt.plot([0, 1], [0, 1], linestyle='--')
# plot the roc curve for the model
plt.plot(fpr_rf, tpr_rf, marker='.')
# show the plot
plt.show()
###############################################################################
###k-fold cross validation
from sklearn.model_selection import cross_val_score
accuracy_k_fold=cross_val_score(estimator=classifier,X=X_train, y=y_train,cv=10)
accuracy_k_fold.mean()
accuracy_k_fold.std()
############################################################################
###################
#Oversample in Predictive Modeling
#Synthetic Minority Oversampling Technique
##########
invoice_data.columns
invoice_data.Delay_Status.value_counts(normalize=True)
from imblearn.over_sampling import SMOTE
X_train1, X_test1, y_train1, y_test1 = train_test_split(X_filtered, y, test_size=0.20, random_state=12)
sm = SMOTE(random_state=12, ratio = 1.0,k_neighbors =3)
X_train_res, y_train_res = sm.fit_sample(X_train1, y_train1)
from sklearn.linear_model import LogisticRegression
classifier_SMOT = LogisticRegression(random_state = 0)
classifier_SMOT.fit(X_train_res, y_train_res)

# Predicting the Test set results
y_pred1 = classifier_SMOT.predict(X_test1)

# Making the Confusion Matrix
from sklearn.metrics import confusion_matrix
cm1 = confusion_matrix(y_test1, y_pred1)
#Accuracy score
from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import roc_curve
accuracy_logistic_SMOT=accuracy_score(y_test1,y_pred1)
#accuracy_logistic 0.6934753661784288
# recall score
# predict probabilities
probs = classifier_SMOT.predict_proba(X_test1)
# keep probabilities for the positive outcome only
probs = probs[:, 1]
# calculate AUC
auc1 = roc_auc_score(y_test1, probs)
print('AUC: %.3f' % auc1)
# calculate roc curve
fpr1, tpr1, thresholds1 = roc_curve(y_test1, probs)
plt.plot([0, 1], [0, 1], linestyle='--')
# plot the roc curve for the model
plt.plot(fpr, tpr, marker='.')
# show the plot
plt.show()
#######################################################################
###binning
##bins=[-100000,0,100000,500000,1000000,1500000]
####group name
##group_names=['-100-0K','0-100K','100-500K','500K-1M','1M-1.5M']
##invoice_data['amount_group']=pd.cut(invoice_data.acctd_amount_due_original,bins,labels=group_names)
##invoice_data['amount_group']=invoice_data['amount_group'].astype('category')

##invoice_data['ship_to_customer_name']=invoice_data['ship_to_customer_name'].astype('category')
##invoice_data['open_item_ar_type_desc']=invoice_data['open_item_ar_type_desc'].astype('category')
#invoice_data.columns
#
#####drop nan
#invoice_data.dropna(subset=['segment'],inplace=True)
#invoice_data['segment'] = (invoice_data['segment'].str.split()).apply(lambda x: float(x[0].replace('', '-')))

#invoice_data.to_csv("submission.csv", index = False, sep=',')
#invoice_data=pd.get_dummies(invoice_data,columns=['amount_group'],drop_first=True)
#invoice_data=pd.get_dummies(invoice_data,columns=['component_code'],drop_first=True)
##invoice_data=pd.get_dummies(invoice_data,columns=['ordering_customer_name'],drop_first=True)
#invoice_data=pd.get_dummies(invoice_data,columns=['ship_to_customer_city_name'],drop_first=True)
#invoice_data=pd.get_dummies(invoice_data,columns=['segment'],drop_first=True)

#invoice_data=pd.get_dummies(invoice_data,columns=['payment_term_name'],drop_first=True)
#invoice_data=pd.get_dummies(invoice_data,columns=['ship_to_customer_name'],drop_first=True)
##deviding dependent and independent variables
#X = invoice_data.drop(['Paid_Time'],axis=1).values
#y = invoice_data.iloc[:, 7:8].values
#from sklearn.preprocessing import LabelEncoder,OneHotEncoder
#le=LabelEncoder()
#X[:,2]=le.fit_transform(X[:,2])
#le1=LabelEncoder()
#X[:,3]=le1.fit_transform(X[:,3])
#le2=LabelEncoder()
#X[:,4]=le2.fit_transform(X[:,4])
#le3=LabelEncoder()
#X[:,5]=le3.fit_transform(X[:,5])
#le4=LabelEncoder()
#X[:,6]=le4.fit_transform(X[:,6])
#le5=LabelEncoder()
#X[:,7]=le5.fit_transform(X[:,7])
#ohe = OneHotEncoder(categorical_features=[1,2,3,4,5,6])
#X = ohe.fit_transform(X).toarray()