//
//  EventLocQuality.h
//  ISKN_API
//
//  Created by Rabeb ALOUI on 18/12/2017.
//  Copyright © 2017 ISKN. All rights reserved.
//

#ifndef EventLocQuality_h
#define EventLocQuality_h

#include "GlobalDefines.h"

namespace ISKN_API
{
    /*!
     * \class EventlocQuality
     * \brief Contains informations about the quality of localisation
     */
    CLASS EventLocQuality
    {
        public :
      
        /*!
         * \brief getLocStatus : it indicates whether the pen localisation is disturbed or not
         * \return the status of localisation :
         * \    status ok                 = 0x00
         * \    status disturber detected = 0x01
         * \    status bad initialization = 0x02
         */
        unsigned char getLocStatus();
        
        /*!
         * \brief getDisturbanceLevel
         * \return global level of perturbation of the Slate (between 0 and 255)
         */
        unsigned char getDisturbanceLevel();
        
        /*!
         * \brief getInnovation
         * \return an array of 32 indicators of perturbation between 0 and 255 per sensor
         */
        char * getInnovation ();
        
        
        private :
        
        char tNormInnovation[32];
        unsigned char Disturbance;
        unsigned char LocStatus;
        
    };
    END_CLASS
}

#endif /* EventLocQuality_h */
