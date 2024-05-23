// Code generated by mockery v2.28.1. DO NOT EDIT.

package mocks

import (
	context "context"
	big "math/big"

	common "github.com/ethereum/go-ethereum/common"

	mock "github.com/stretchr/testify/mock"

	time "time"

	txmgr "github.com/ethereum-optimism/optimism/op-service/txmgr"

	types "github.com/ethereum/go-ethereum/core/types"
)

// TxManager is an autogenerated mock type for the TxManager type
type TxManager struct {
	mock.Mock
}

// BlockNumber provides a mock function with given fields: ctx
func (_m *TxManager) BlockNumber(ctx context.Context) (uint64, error) {
	ret := _m.Called(ctx)

	var r0 uint64
	var r1 error
	if rf, ok := ret.Get(0).(func(context.Context) (uint64, error)); ok {
		return rf(ctx)
	}
	if rf, ok := ret.Get(0).(func(context.Context) uint64); ok {
		r0 = rf(ctx)
	} else {
		r0 = ret.Get(0).(uint64)
	}

	if rf, ok := ret.Get(1).(func(context.Context) error); ok {
		r1 = rf(ctx)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Close provides a mock function with given fields:
func (_m *TxManager) Close() {
	_m.Called()
}

// From provides a mock function with given fields:
func (_m *TxManager) From() common.Address {
	ret := _m.Called()

	var r0 common.Address
	if rf, ok := ret.Get(0).(func() common.Address); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(common.Address)
		}
	}

	return r0
}

// GetBumpFeeRetryTime provides a mock function with given fields:
func (_m *TxManager) GetBumpFeeRetryTime() time.Duration {
	ret := _m.Called()

	var r0 time.Duration
	if rf, ok := ret.Get(0).(func() time.Duration); ok {
		r0 = rf()
	} else {
		r0 = ret.Get(0).(time.Duration)
	}

	return r0
}

// GetFeeThreshold provides a mock function with given fields:
func (_m *TxManager) GetFeeThreshold() *big.Int {
	ret := _m.Called()

	var r0 *big.Int
	if rf, ok := ret.Get(0).(func() *big.Int); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*big.Int)
		}
	}

	return r0
}

// GetMinBaseFee provides a mock function with given fields:
func (_m *TxManager) GetMinBaseFee() *big.Int {
	ret := _m.Called()

	var r0 *big.Int
	if rf, ok := ret.Get(0).(func() *big.Int); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*big.Int)
		}
	}

	return r0
}

// GetMinBlobFee provides a mock function with given fields:
func (_m *TxManager) GetMinBlobFee() *big.Int {
	ret := _m.Called()

	var r0 *big.Int
	if rf, ok := ret.Get(0).(func() *big.Int); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*big.Int)
		}
	}

	return r0
}

// GetPendingTxs provides a mock function with given fields:
func (_m *TxManager) GetPendingTxs() ([]*types.Transaction, error) {
	ret := _m.Called()

	var r0 []*types.Transaction
	var r1 error
	if rf, ok := ret.Get(0).(func() ([]*types.Transaction, error)); ok {
		return rf()
	}
	if rf, ok := ret.Get(0).(func() []*types.Transaction); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).([]*types.Transaction)
		}
	}

	if rf, ok := ret.Get(1).(func() error); ok {
		r1 = rf()
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// GetPriorityFee provides a mock function with given fields:
func (_m *TxManager) GetPriorityFee() *big.Int {
	ret := _m.Called()

	var r0 *big.Int
	if rf, ok := ret.Get(0).(func() *big.Int); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*big.Int)
		}
	}

	return r0
}

// IsClosed provides a mock function with given fields:
func (_m *TxManager) IsClosed() bool {
	ret := _m.Called()

	var r0 bool
	if rf, ok := ret.Get(0).(func() bool); ok {
		r0 = rf()
	} else {
		r0 = ret.Get(0).(bool)
	}

	return r0
}

// Send provides a mock function with given fields: ctx, candidate
func (_m *TxManager) Send(ctx context.Context, candidate txmgr.TxCandidate) (*types.Receipt, error) {
	ret := _m.Called(ctx, candidate)

	var r0 *types.Receipt
	var r1 error
	if rf, ok := ret.Get(0).(func(context.Context, txmgr.TxCandidate) (*types.Receipt, error)); ok {
		return rf(ctx, candidate)
	}
	if rf, ok := ret.Get(0).(func(context.Context, txmgr.TxCandidate) *types.Receipt); ok {
		r0 = rf(ctx, candidate)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*types.Receipt)
		}
	}

	if rf, ok := ret.Get(1).(func(context.Context, txmgr.TxCandidate) error); ok {
		r1 = rf(ctx, candidate)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// SetBumpFeeRetryTime provides a mock function with given fields: _a0
func (_m *TxManager) SetBumpFeeRetryTime(_a0 time.Duration) {
	_m.Called(_a0)
}

// SetFeeThreshold provides a mock function with given fields: _a0
func (_m *TxManager) SetFeeThreshold(_a0 *big.Int) {
	_m.Called(_a0)
}

// SetMinBaseFee provides a mock function with given fields: _a0
func (_m *TxManager) SetMinBaseFee(_a0 *big.Int) {
	_m.Called(_a0)
}

// SetMinBlobFee provides a mock function with given fields: _a0
func (_m *TxManager) SetMinBlobFee(_a0 *big.Int) {
	_m.Called(_a0)
}

// SetPriorityFee provides a mock function with given fields: _a0
func (_m *TxManager) SetPriorityFee(_a0 *big.Int) {
	_m.Called(_a0)
}

type mockConstructorTestingTNewTxManager interface {
	mock.TestingT
	Cleanup(func())
}

// NewTxManager creates a new instance of TxManager. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
func NewTxManager(t mockConstructorTestingTNewTxManager) *TxManager {
	mock := &TxManager{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}
