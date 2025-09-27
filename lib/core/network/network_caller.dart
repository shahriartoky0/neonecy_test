import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'network_response.dart';

class NetworkCaller {
  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponse> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
        bool isFormData = false, // New parameter to specify form data
      }) async {
    final Uri uri = Uri.parse(url);

    // Set headers based on content type
    final Map<String, String> requestHeaders = <String, String>{
      if (!isFormData) 'Content-Type': 'application/json',
      if (isFormData) 'Content-Type': 'application/x-www-form-urlencoded',
      ...?headers,
    };

    try {
      Response response;
      String? requestBody;

      // Prepare body based on content type
      if (body != null) {
        if (isFormData) {
          // Convert Map to form-encoded string
          requestBody = body.entries
              .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
              .join('&');
        } else {
          // JSON encode for regular requests
          requestBody = jsonEncode(body);
        }
      }

      switch (method.toUpperCase()) {
        case 'POST':
          response = await post(
            uri,
            headers: requestHeaders,
            body: requestBody,
          );
          break;
        case 'GET':
          response = await get(uri, headers: requestHeaders);
          break;
        case 'PUT':
          response = await put(
            uri,
            headers: requestHeaders,
            body: requestBody,
          );
          break;
        case 'DELETE':
          response = await delete(uri, headers: requestHeaders);
          break;
        case 'PATCH':
          response = await patch(
            uri,
            headers: requestHeaders,
            body: requestBody,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('Error: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  NetworkResponse _handleResponse(Response response, bool isLogin) {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 401 && !isLogin) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
        );
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // POST Request with form data support
  Future<NetworkResponse> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
        bool isFormData = false, // New parameter
      }) async {
    return _request(
      'POST',
      url,
      body: body,
      isLogin: isLogin,
      headers: headers,
      isFormData: isFormData,
    );
  }

  // Form data specific POST request
  Future<NetworkResponse> postFormData(
      String url, {
        required Map<String, dynamic> formData,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return postRequest(
      url,
      body: formData,
      isLogin: isLogin,
      headers: headers,
      isFormData: true,
    );
  }

  // Other methods remain the same but can be extended similarly
  Future<NetworkResponse> getRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('GET', url, body: body, isLogin: isLogin, headers: headers);
  }

  Future<NetworkResponse> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
        bool isFormData = false,
      }) async {
    return _request('PUT', url, body: body, isLogin: isLogin, headers: headers, isFormData: isFormData);
  }

  Future<NetworkResponse> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('DELETE', url, body: body, isLogin: isLogin, headers: headers);
  }

  Future<NetworkResponse> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
        bool isFormData = false,
      }) async {
    return _request('PATCH', url, body: body, isLogin: isLogin, headers: headers, isFormData: isFormData);
  }
}