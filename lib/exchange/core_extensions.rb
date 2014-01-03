# -*- encoding : utf-8 -*-
require 'exchange/core_extensions/numeric/conversability'
require 'exchange/core_extensions/float/error_safe'
require 'exchange/core_extensions/cachify'
require 'exchange/core_extensions/big_decimal/mri_2_1_0_patch' if Exchange::BROKEN_BIG_DECIMAL_DIVISION
