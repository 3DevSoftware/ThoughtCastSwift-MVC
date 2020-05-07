/*!
 * \file Device.h
 * \brief Device
 * \author ISKN TEAM
 * \version 0.1
 * \date 31/01/2015
 *
 * This file is part of the "ISKN" library.
 * For conditions of distribution and use, see copyright notice in ISKN_API.h
*/

#ifndef ISKN_DEVICE_H
#define ISKN_DEVICE_H

#include "GlobalDefines.h"
#include "FileSystem.h"

namespace ISKN_API
{

/*!
 * \class Device
 * \brief This class contains the device information like Slate name, firmware version, the width, the height...
 */
CLASS Device : public FileSystem
{

public:
    /*!
     * \brief Device
     * \warning internal use only
     */
    Device(void *p);

    virtual ~Device();

    /*!
     * \brief Gets the slate ID
     * \return the Slate name
     */
    char * getDeviceName();


    /*!
     * \brief Changes the slate name
     * \param newName the new Slate name
     * \return true if succeeded, otherwise it returns false
     */
    bool setDeviceName(char *newName);

    /*!
     * \brief Returns the slate firmware version
     * \return firmware version : XXX.XXX.XXX.XXX
     */
    char *getFirmwareVersion();


    /*!
     * \brief Returns the slate width
     * \return width
     */
    float getWidth();

    /*!
     * \brief Returns the slate height
     * \return height
     */
    float getHeight();

    /*!
     * \brief Returns the slate size
     * \return  a Size object
     */
    const Size &getSlateSize();

    /*!
     * \brief Returns the slate coordinates and size of the active zone
     * \return a Rect object
     */
    const Rect &getActiveZone();

    /*!
     * \brief Gets the slate coordinates and size of the active zone in independent parameters
     * \param left left start coordinate
     * \param top top start coordinate
     * \param width width of the client space
     * \param height height of the client space
     * \return true on success, false if an error occurred
     */
    bool getActiveZoneParameters(float &left, float &top, float &width, float &height);

    /*!
     * \brief Returns last battery charge
     * \return last battery charge
     */
    float getBatteryCharge();

    /*!
     * \brief Returns battery status
     * \return true if there is the battery is in charge , otherwise it returns false
     */
    bool isBatteryInCharge();

    /*!
     * \brief Sets the slate internal time
     * \param dt ISKN datetime class object
     * \param t ISKN time class object
     * \return true if succeeded, otherwise it returns false
     */
    bool setDateTime(const ISKNDate &dt, const ISKNTime &t);

   
    /*!
     * \brief Changes Localisation Quality parameters
     * \param idleFrequency the frequency of sending in Idle state (No Pen is detected on the Slate surface)
     * \param warningFrequency the frequency of sending in Localization state (A pen is localized on the Slate surface)
     */
    void setLocQualityParameters(float idleFrequency, float warningFrequency);
    
    /*!
     * \brief refresh
     * \
     */
    void refresh();


private :
    /*!
    * \brief pInternals
    * \warning Don't use this (internal use only)
    */
    void *pInternals;
} ;

END_CLASS

}

#endif // ISKN_DEVICE_H

