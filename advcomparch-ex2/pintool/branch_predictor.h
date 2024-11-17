#ifndef BRANCH_PREDICTOR_H
#define BRANCH_PREDICTOR_H

#include <sstream> // std::ostringstream
#include <cmath>   // pow(), floor
#include <cstring> // memset()

/**
 * A generic BranchPredictor base class.
 * All predictors can be subclasses with overloaded predict() and update()
 * methods.
 **/
class BranchPredictor
{
public:
    BranchPredictor() : correct_predictions(0), incorrect_predictions(0) {};
    ~BranchPredictor() {};
    //Predict: wants to predict if the jump will be done or not(Taken/Not Taken)
    //arguments of predict--> PC of command , destination address
    virtual bool predict(ADDRINT ip, ADDRINT target) = 0;
    //update: saves information for fututre predictions
    //arguments of update--> predictor's prediction, real result, PC, destination address
    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) = 0;
    //get name--> prints results of branch predictor in the output file of pintool
    virtual string getName() = 0;

    UINT64 getNumCorrectPredictions() { return correct_predictions; }
    UINT64 getNumIncorrectPredictions() { return incorrect_predictions; }

   void resetCounters() { correct_predictions = incorrect_predictions = 0; };

protected:
    void updateCounters(bool predicted, bool actual) {
        if (predicted == actual)
            correct_predictions++;
        else
            incorrect_predictions++;
    };

private:
    UINT64 correct_predictions;
    UINT64 incorrect_predictions;
};

class NbitPredictor : public BranchPredictor
{
public:
    NbitPredictor(unsigned index_bits_, unsigned cntr_bits_)
        : BranchPredictor(), index_bits(index_bits_), cntr_bits(cntr_bits_) {
        table_entries = 1 << index_bits;
        TABLE = new unsigned long long[table_entries];
        memset(TABLE, 0, table_entries * sizeof(*TABLE));
        
        COUNTER_MAX = (1 << cntr_bits) - 1;
    };
    ~NbitPredictor() { delete TABLE; };
    
    virtual bool predict(ADDRINT ip, ADDRINT target) {
        unsigned int ip_table_index = ip % table_entries;
        unsigned long long ip_table_value = TABLE[ip_table_index];
        unsigned long long prediction = ip_table_value >> (cntr_bits - 1);
        return (prediction != 0);
    };

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
        unsigned int ip_table_index = ip % table_entries; //take the index of the current branch instruction
        if (actual) { //if is taken
            if (TABLE[ip_table_index] < COUNTER_MAX)
                TABLE[ip_table_index]++; //we are closer to predicting "taken"
        } else {
            if (TABLE[ip_table_index] > 0)
                TABLE[ip_table_index]--; //we are closer to predicting "not-taken"
        }
        
        updateCounters(predicted, actual);
    };

    virtual string getName() {
        std::ostringstream stream;
        stream << "Nbit-" << pow(2.0,double(index_bits)) / 1024.0 << "K-" << cntr_bits;
        return stream.str();
    }

private:
    unsigned int index_bits, cntr_bits;
    unsigned int COUNTER_MAX;
    
    /* Make this unsigned long long so as to support big numbers of cntr_bits. */
    unsigned long long *TABLE;
    unsigned int table_entries;
};


class TwobitPredictor : public BranchPredictor
{
public:
    TwobitPredictor(unsigned index_bits_, unsigned cntr_bits_)
        : BranchPredictor(), index_bits(index_bits_), cntr_bits(cntr_bits_) {
        table_entries = 1 << index_bits; //-->2^(index_bits)
        TABLE = new unsigned long long[table_entries];
        memset(TABLE, 0, table_entries * sizeof(*TABLE));
        
        COUNTER_MAX = (1 << cntr_bits) - 1;
    };
    ~TwobitPredictor() { delete TABLE; };
    
    virtual bool predict(ADDRINT ip, ADDRINT target) {
        unsigned int ip_table_index = ip % table_entries;
        unsigned long long ip_table_value = TABLE[ip_table_index];
        unsigned long long prediction = ip_table_value >> (cntr_bits - 1);
        return (prediction != 0);
    };

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
        unsigned int ip_table_index = ip % table_entries;
        if (actual) {
            //if we are on 10 and branch is taken then we go to 11
            if (TABLE[ip_table_index] == 1)
                TABLE[ip_table_index] = 3;
            else if(TABLE[ip_table_index] < COUNTER_MAX){
            	TABLE[ip_table_index]++; //we get closer to predicting "taken"
            }
            
        } else {
            if (TABLE[ip_table_index] == 2)
                TABLE[ip_table_index] = 0;
            else if(TABLE[ip_table_index] > 0){
            	TABLE[ip_table_index]--;
            }
        }
        
        updateCounters(predicted, actual);
    };

    virtual string getName() {
        std::ostringstream stream;
        stream << "2bit-" << pow(2.0,double(index_bits)) / 1024.0 << "K-" << cntr_bits;
        return stream.str();
    }

private:
    unsigned int index_bits, cntr_bits;
    unsigned int COUNTER_MAX;
    
    /* Make this unsigned long long so as to support big numbers of cntr_bits. */
    unsigned long long *TABLE;
    unsigned int table_entries;
};






// Fill in the BTB implementation ...
class BTBPredictor : public BranchPredictor
{
public:
	BTBPredictor(int btb_lines, int btb_assoc)
	     : table_lines(btb_lines), table_assoc(btb_assoc)
	{
		/* ... fill me ... */
	}

	~BTBPredictor() {
		/* ... fill me ... */
	}

    virtual bool predict(ADDRINT ip, ADDRINT target) {
		/* ... fill me ... */
		return false;
	}

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
		/* ... fill me ... */
	}

    virtual string getName() { 
        std::ostringstream stream;
		stream << "BTB-" << table_lines << "-" << table_assoc;
		return stream.str();
	}

    UINT64 getNumCorrectTargetPredictions() { 
		/* ... fill me ... */
		return 0;
	}

private:
	int table_lines, table_assoc;
};


// Fill in the perceptron implementation ...
class PerceptronPredictor : public BranchPredictor
{

public:
	PerceptronPredictor(int _perceptronTableSize, int _historyLength) : perceptronTableSize(_perceptronTableSize), historyLength(_historyLength) {
		/* ... fill me ... */
		//kTheta = floor();
    } 
	
	~PerceptronPredictor() {
		/* ... fill me ... */
	}

    virtual bool predict(ADDRINT ip, ADDRINT target) {
		/* ... fill me ... */
		return false;
	}

    virtual void update(bool predicted, bool actual, ADDRINT ip, ADDRINT target) {
		/* ... fill me ... */
	}

    virtual string getName() { 
        std::ostringstream stream;
		stream << "Perceptron (" << perceptronTableSize << "," << historyLength << ")";
		return stream.str();
	}

    UINT64 getNumCorrectTargetPredictions() { 
		/* ... fill me ... */
		return 0;
	}


private:
	//Table of perceptrons and its number of entries
	std::vector<std::vector<int>> weightsTable;
	int perceptronTableSize;
	
	// Global History Register and its length
	std::vector<int> history;
	int historyLength;

	//As a threshold we use the optimal value as discussed in the paper (go
	//read the paper!)
	int kTheta;
};

#endif
