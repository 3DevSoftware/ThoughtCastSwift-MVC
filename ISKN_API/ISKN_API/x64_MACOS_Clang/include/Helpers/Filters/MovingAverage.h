//
//  file MovingAverage.h
//  ISKN_API
//
//  Created by Rabeb ALOUI on 12/03/2018.
//  Copyright © 2018 ISKN. All rights reserved.
//

#ifndef MovingAverage_h
#define MovingAverage_h

#include <deque>
#include "Filter.h"
using namespace std;

namespace ISKN_API
{
    class MovingAverage: public Filter
    {
        public:
        
        MovingAverage(int order, int nb_channels);
        vector<float> process(vector<float> x);
        void reset();
        
        vector<deque<double>> buffers;
    };
}

#endif /* MovingAverage_h */
