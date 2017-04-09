#!/usr/bin/env python
# -*- coding: utf-8 -*-


class CosErr(object):
    """sdk错误码"""
    PARAMS_ERROR = -1  # 参数错误
    NETWORK_ERROR = -2  # 网络错误
    SERVER_ERROR = -3  # server端返回错误
    UNKNOWN_ERROR = -4  # 未知错误

    @staticmethod
    def get_err_msg(errcode, err_info):
        return {u'code': errcode, u'message': err_info}
