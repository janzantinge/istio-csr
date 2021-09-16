/*
Copyright 2021 The cert-manager Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package fake

import (
	"context"
	"crypto/tls"
	"crypto/x509"

	cmtls "github.com/cert-manager/istio-csr/pkg/tls"
)

var _ cmtls.Interface = &FakeTLS{}

// FakeTLS is a fake implementation of tls.Interface that can be used for testing.
type FakeTLS struct {
	funcTrustDomain func() string
	funcRootCAs     func() ([]byte, *x509.CertPool)
	funcConfig      func(ctx context.Context) (*tls.Config, error)
}

func New() *FakeTLS {
	return &FakeTLS{
		funcTrustDomain: func() string { return "" },
		funcRootCAs:     func() ([]byte, *x509.CertPool) { return nil, nil },
		funcConfig:      func(_ context.Context) (*tls.Config, error) { return nil, nil },
	}
}

func (f *FakeTLS) WithRootCAs(rootCAsPEM []byte, rootCAsPool *x509.CertPool) *FakeTLS {
	f.funcRootCAs = func() ([]byte, *x509.CertPool) { return rootCAsPEM, rootCAsPool }
	return f
}

func (f *FakeTLS) TrustDomain() string {
	return f.funcTrustDomain()
}

func (f *FakeTLS) RootCAs() ([]byte, *x509.CertPool) {
	return f.funcRootCAs()
}

func (f *FakeTLS) Config(ctx context.Context) (*tls.Config, error) {
	return f.funcConfig(ctx)
}
