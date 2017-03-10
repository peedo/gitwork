//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//----------------------------------------------------------------------------

#ifndef __MBED_CLOUD_CLIENT_H__
#define __MBED_CLOUD_CLIENT_H__

#include <map>
#include <string>
#include <vector>
#include "include/ServiceClient.h"

using namespace std;
class SimpleM2MResourceBase;

/**
 * \brief MbedCloudClientCallback
 * A callback class for informing updated object and resource value from the
 * LWM2M server to the user of the MbedCloudClient class. The user MUST instantiate the
 * class derived out of this and pass the object to MbedCloudClient::set_update_callback().
 */
class MbedCloudClientCallback {

public:

    /**
    * \brief A callback indicating that the value of the resource object is updated
    *  by the LWM2M Cloud server.
    * \param base The object whose value is updated.
    * \param type The type of the object.
    */
    virtual void value_updated(M2MBase *base, M2MBase::BaseType type) = 0;
};



/*! \file MbedCloudClient.h
 *  \brief MbedCloudClient.
 *  This class provides an interface for handling all the mbed Cloud Client Interface operations
 *  including device provisioning, identity setup, device resource management defined in the OMA
 *  LWM2M specifications, and update firmware.
 *  Device resource management includes Bootstrapping, Client Registration, Device Management &
 *  Service Enablement and Information Reporting.
 */

class MbedCloudClient : public ServiceClientCallback{

public:

    /**
     * \brief An enum defining different kinds of errors
     * that can occur during various client operations.
     */
    typedef enum {
        IdentityError                           = 0x01, // Range reserved for Identity Error from 0x01 - 0x2F
        IdentityInvalidParameter,
        IdentityOutofMemory,
        IdentityProvisioningError,
        IdentityInvalidSessionID,
        IdentityNetworkError,
        IdentityInvalidMessageType,
        IdentityInvalidMessageSize,
        IdentityCertOrKeyNotFound,
        IdentityRetransmissionError,
        ConnectErrorNone                        = 0x30, // Range reserved for Connector Error from 0x30 - 0x5F
        ConnectAlreadyExists,
        ConnectBootstrapFailed,
        ConnectInvalidParameters,
        ConnectNotRegistered,
        ConnectTimeout,
        ConnectNetworkError,
        ConnectResponseParseFailed,
        ConnectUnknownError,
        ConnectMemoryConnectFail,
        ConnectNotAllowed,
        ConnectSecureConnectionFailed,
        ConnectDnsResolvingFailed
#ifdef MBED_CLOUD_CLIENT_SUPPORT_UPDATE
        , UpdateErrorBase                       = UpdateClient::ErrorBase, // Range reserved for Update Error from 0x0400 - 0x04FF
        UpdateWarningCertificateNotFound        = UpdateClient::WarningCertificateNotFound,
        UpdateWarningCertificateInvalid         = UpdateClient::WarningCertificateInvalid,
        UpdateWarningSignatureInvalid           = UpdateClient::WarningSignatureInvalid,
        UpdateWarningVendorMismatch             = UpdateClient::WarningVendorMismatch,
        UpdateWarningClassMismatch              = UpdateClient::WarningClassMismatch,
        UpdateWarningDeviceMismatch             = UpdateClient::WarningDeviceMismatch,
        UpdateWarningURINotFound                = UpdateClient::WarningURINotFound,
        UpdateErrorUserActionRequired,
        UpdateFatalRebootRequired
#endif
    }Error;

#ifdef MBED_CLOUD_CLIENT_SUPPORT_UPDATE
    /**
     * \brief Enum defining authorization requests from the Update client.
     */
    enum {
        UpdateRequestInvalid                    = UpdateClient::RequestInvalid,
        UpdateRequestDownload                   = UpdateClient::RequestDownload,
        UpdateRequestInstall                    = UpdateClient::RequestInstall
    };
#endif

    /**
     * \brief Constructor
     */
    MbedCloudClient();

    /**
     * \brief Destructor
     */
    ~MbedCloudClient();

    /**
     * \brief Adds a list of objects that the application wants to register to the
     * LWM2M server. This function MUST be called before calling the setup()
     * API. Otherwise, the application gets the error ConnectInvalidParameters, when
     * calling setup().
     * \param object_list Objects that contain information about the
     * client attempting to register to the LWM2M server.
     */
    void add_objects(const M2MObjectList& object_list);

    /**
     * \brief Sets the callback function that is called when there is
     * any new update on any Object/ObjectInstance/Resource from the LWM2M server,
     * typically on receiving PUT commands on the registered objects.
     * \param callback Passes the class object that implements the callback
     * function to handle the incoming PUT request on a given object.
     */
    void set_update_callback(MbedCloudClientCallback *callback);

    /**
     * \brief Initiates the Cloud Client set up on the Cloud service. This
     * function manages device provisioning (first time usage), bootstrapping
     * (first time usage) and registering the client application to the Cloud
     * service.
     * \param iface A handler to the network interface on mbedOS, can be NULL on
     * other platforms.
     */
    bool setup(void* iface);

    /**
     * \brief Sets the callback function that is called when the client is registered
     * successfully to the Cloud. This is used for a statically defined function.
     * \param fn A function pointer to the function that is called when the client
     * is registered.
     */
    void on_registered(void(*fn)(void));

    /**
    * \brief Sets the callback function that is called when the client is registered
    * successfully to the Cloud. This is an overloaded function for a class function.
    * \param object A function pointer to the function that is called when the client
    * is registered.
    */
    template<typename T>
    void on_registered(T *object, void (T::*member)(void));

    /**
     * \brief Sets the callback function that is called when there is any error
     * occuring in the client functionality. The error code can be mapped from the
     * MbedCloudClient::Error enum. This is used for a statically defined function.
     * \param fn A function pointer to the function that is called when there
     * is any error in the client.
     */
    void on_error(void(*fn)(int));

    /**
     * \brief Sets the callback function that is called when there is an error
     * occuring in the client functionality. The error code can be mapped from
     * MbedCloudClient::Error enum. This is an overloaded function for a class function.
     * \param object A function pointer to the function that is called when there
     * is an error in the client.
     */
    template<typename T>
    void on_error(T *object, void (T::*member)(int));

    /**
     * \brief Sets the callback function that is called when the client is unregistered
     * successfully from the Cloud. This is used for a statically defined function.
     * \param fn A function pointer to the function that is called when the client
     * is unregistered.
     */
    void on_unregistered(void(*fn)(void));

    /**
    * \brief Sets the callback function that is called when the client is unregistered
    * successfully from the Cloud. This is an overloaded function for a class function.
    * \param object A function pointer to the function that is called when the client
    * is unregistered.
    */
    template<typename T>
    void on_unregistered(T *object, void (T::*member)(void));

    /**
    * \brief Sends a registration update message to the Cloud when the client is registered
    * successfully to the Cloud and there is no internal connection error.
    * If the client is not connected and there is some other internal network
    * transaction ongoing, this function triggers an error MbedCloudClient::ConnectNotAllowed.
    */
    void keep_alive();

    /**
    * \brief Closes the connection towards Cloud and unregisters the client.
    * This function triggers the on_unregistered() callback if set by the application.
    */
    void close();

    /**
     * \brief Returns pointer to the ConnectorClientServerInfo object.
     * \return ConnectorClientServerInfo pointer.
     */
    const ConnectorClientServerInfo *server_info() const;

    /**
     * \brief Set resource value in the Device Object
     *
     * \param resource Device enum to have value set.
     * \param value String object.
     * \return True if successful, false otherwise.
     */
    bool set_device_resource_value(M2MDevice::DeviceResource resource,
                                   const std::string &value);

#ifdef MBED_CLOUD_CLIENT_SUPPORT_UPDATE
    /**
     * \brief Registers a callback function for authorizing firmware downloads and reboots.
     * \param handler Callback function.
     */
    void set_update_authorize_handler(void (*handler)(int32_t request));

    /**
     * \brief Authorize request passed to authorization handler.
     * \param request Request being authorized.
     */
    void update_authorize(int32_t request);

    /**
     * \brief Registers a callback function for monitoring download progress.
     * \param handler Callback function.
     */
    void set_update_progress_handler(void (*handler)(uint32_t progress, uint32_t total));
#endif

protected: // from ServiceClientCallback

    /**
    * \brief Indicates that the setup or close operation is complete
    * with success or failure.
    * \param status Indicates success or failure in terms of status code.
    */
    virtual void complete(int status);

    /**
    * \brief Indicates an error condition from the underlying clients like
    * identity, connector or update client.
    * \param error Indicates an error code translated to MbedCloudClient::Error.
    */
    virtual void error(int error);

    /**
    * \brief A callback indicating that the value of the resource object is updated
    *  by the LWM2M Cloud server.
    * \param base The object whose value is updated.
    * \param type The type of the object.
    */
    virtual void value_updated(M2MBase *base, M2MBase::BaseType type);

private:

    /**
    * \brief Returns the binding mode selected by the client
    * through the configuration.
    * \return Binding mode of the client.
    */
    M2MInterface::BindingMode transport_mode();

    /**
    * \brief Registers the update callback functions for SimpleM2MResourceBase
    * objects.
    * \param route The URI path of the registered resource such as "/Test/0/res/".
    * \param resource Object of the SimpleM2MResourceBase.
    */
    void register_update_callback(string route, SimpleM2MResourceBase* resource);

private:

    ServiceClient                                   *_client;
    MbedCloudClientCallback                         *_value_callback;
    map<string, M2MObject*>                         _objects;
    map<string, M2MResource*>                       _resources;
    struct ConnectorClientInterfaceInfo             _interface_info;
    M2MObjectList                                   _object_list;
    map<string, SimpleM2MResourceBase*>             _update_values;
    FP0<void>                                       _on_registered;
    FP0<void>                                       _on_unregistered;
    FP1<void,int>                                   _on_error;

friend class SimpleM2MResourceBase;
};


#endif // __MBED_CLOUD_CLIENT_H__
