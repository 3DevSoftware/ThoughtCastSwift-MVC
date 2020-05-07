//
//  file Filter.h
//  ISKN_API
//
//  Created by Rabeb ALOUI on 12/03/2018.
//  Copyright © 2018 ISKN. All rights reserved.
//

#ifndef FILTER_H
#define FILTER_H

#include <iostream>
#include <vector>
using namespace std;

namespace ISKN_API
{
    //=======================================================================================
    //                           Internal class: Filter_BadInputSizeException
    //=======================================================================================

    /*! \class Filter_BadInputSizeException
     * \brief Exception raised by filter class
     *  If the size of the input vector of the process function is not the same as the channels number
     *  declared when constructing the filter this exception is raised.
     */
    class Filter_BadInputSizeException:public exception
    {
    public:
        /*!
         *  \brief Constructor
         *  \param input_vector_size : the input vector size.
         *  \param nb_channels : number of filter channels.
         */
        Filter_BadInputSizeException(int input_vector_size, int nb_channels) throw()
        {
            sprintf(m_message, "Bad input size. Supported input size = %d, presented input size = %d",nb_channels, input_vector_size);
        }
        
        /*!
         *  \brief Returns a string that describes the exception
         */
        virtual const char* what() const throw()
        {
            return m_message;
        }
        
        /*!
         *  \brief Destructor
         */
        virtual ~Filter_BadInputSizeException() throw()
        {}
        
    private:
        char m_message[100];  //Error description
    };
    
    
    //=======================================================================================
    //                                     Filter class
    //=======================================================================================
    
    /*! \class Filter
     * \brief Main cass for muti_channels filters
     */
    class Filter
    {
    public:
        
        /*!
         *  \brief Constructor of the filter
         *
         *  \param order : the order of the filter (the size of the filtering buffer).It must be greater than
         *  (1) to process the filtering. If a bad value is used, the default value (2) is set.
         *  \param nb_channels : the number of signals to filter. It must be greater than (0) to process
         *  filtering.If a bad value is used, the value (1) is set as a default value.
         */
        Filter(int order=2, int nb_channels=1):
        order(order),nb_channels(nb_channels){
            if(order<=1)
                this->order = 2;
            if(nb_channels<=0)
                this->nb_channels = 1;
        }
        
        /*!
         *  \brief Processes the input vector by filtering each of its components.
         *  \param x The input vector. It must have the same size of nb_channels otherwize a
         *  Filter_BadInputSizeException exception will be raised.
         */
        virtual vector<float> process(vector<float> x)=0;
        
        /*!
         *  \brief Resets the filter (clear the buffer). It must be called if a new signal is to be processed.
         */
        virtual void reset()=0;
        
        /*!
         *  \brief The order of the filter (size of the filtering buffer).
         */
        int order;
        
        /*!
         *  \brief The number of independent channels to be filtered.
         */
        int nb_channels;
    };
    }
#endif // FILTER_H
