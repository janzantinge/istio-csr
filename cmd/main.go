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

package main

import (
	"os"

	"k8s.io/klog/v2"
	"sigs.k8s.io/controller-runtime/pkg/manager/signals"

	"github.com/cert-manager/istio-csr/cmd/app"
)

func main() {
	ctx := signals.SetupSignalHandler()
	cmd := app.NewCommand(ctx)

	if err := cmd.Execute(); err != nil {
		klog.ErrorS(err, "error running cert-manager-istio-csr")
		os.Exit(1)
	}
}
