$script:DSCModuleName = 'xNetworking'
$script:DSCResourceName = 'MSFT_xIPAddressOption'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[string] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\xNetworking'
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xIPAddressOption\Get-TargetResource' -Tag 'Get' {
            Context 'Invoked with an existing IP address' {
                Mock -CommandName Get-NetIPAddress -MockWith {
                    [PSCustomObject] @{
                        IPAddress      = '192.168.0.1'
                        InterfaceAlias = 'Ethernet'
                        InterfaceIndex = 1
                        PrefixLength   = [System.Byte] 24
                        AddressFamily  = 'IPv4'
                        SkipAsSource   = $true
                    }
                }
                It 'Should return existing IP options' {
                    $getTargetResourceParameters = @{
                        IPAddress = '192.168.0.1'
                    }
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.IPAddress    | Should Be $getTargetResourceParameters.IPAddress
                    $result.SkipAsSource | Should Be 'True'
                }
            }
        }

        Describe 'MSFT_xIPAddressOption\Set-TargetResource' -Tag 'Set' {
            Context 'Invoked with an existing IP address, SkipAsSource = $false' {
                BeforeEach {
                    Mock -CommandName Get-NetIPAddress -MockWith {
                        [PSCustomObject] @{
                            IPAddress      = '192.168.0.1'
                            InterfaceAlias = 'Ethernet'
                            InterfaceIndex = 1
                            PrefixLength   = [System.Byte] 24
                            AddressFamily  = 'IPv4'
                            SkipAsSource   = $false
                        }
                    }

                    Mock -CommandName Set-NetIPAddress
                }

                Context 'Invoked with valid IP address' {
                    It 'Should return $null' {
                        $setTargetResourceParameters = @{
                            IPAddress    = '192.168.0.1'
                            SkipAsSource = 'True'
                        }
                        { $result = Set-TargetResource @setTargetResourceParameters } | Should Not Throw
                        $result | Should BeNullOrEmpty
                    }

                    It 'Should call all the mock' {
                        Assert-MockCalled -CommandName Set-NetIPAddress -Exactly -Times 1
                    }
                }
            }
        }

        Describe 'MSFT_xIPAddressOption\Test-TargetResource' -Tag 'Test' {
            Context 'Invoked with an existing IP address, SkipAsSource = $true' {
                BeforeEach {
                    Mock -CommandName Get-NetIPAddress -MockWith {
                        [PSCustomObject] @{
                            IPAddress      = '192.168.0.1'
                            InterfaceAlias = 'Ethernet'
                            InterfaceIndex = 1
                            PrefixLength   = [System.Byte] 24
                            AddressFamily  = 'IPv4'
                            SkipAsSource   = $true
                        }
                    }
                }

                Context 'Invoked with valid IP address' {
                    It 'Should return $true' {
                        $testGetResourceParameters = @{
                            IPAddress    = '192.168.0.1'
                            SkipAsSource = 'True'
                        }

                        $result = Test-TargetResource @testGetResourceParameters
                        $result | Should Be $true
                    }
                }
            }
        }
    } #end InModuleScope $DSCResourceName
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
