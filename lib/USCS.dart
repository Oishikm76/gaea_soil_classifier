import 'package:flutter/material.dart';

class USCSPage extends StatefulWidget {
  const USCSPage({super.key});

  @override
  State<USCSPage> createState() => _USCSPageState();
}

class _USCSPageState extends State<USCSPage> {
  // Inputs
  final TextEditingController _pass200Controller = TextEditingController();
  final TextEditingController _llController = TextEditingController();
  final TextEditingController _plController = TextEditingController();
  final TextEditingController _gravelController = TextEditingController();
  final TextEditingController _cuController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();

  String _uscsResult = '';
  String _warningMessage = '';
  bool _organic = false;

  // ---- Helpers -------------------------------------------------------------

  // A-line check: true => on/above A-line (clayey), false => below (silty)
  bool checkALine(double ll, double pi) => pi >= 0.73 * (ll - 20);

  // Map to C (clay) or M (silt) by A-line
  String getFineType(double ll, double pi) => checkALine(ll, pi) ? 'C' : 'M';

  // Parse a number safely
  double? tryParse(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    return double.tryParse(input.trim());
  }

  // ---- Core USCS classification -------------------------------------------

  /// Returns the USCS symbol (e.g., GW, SC-SM, CL-ML, etc.).
  /// Implements the requested rules for sands/gravels with fines > 12%:
  ///  - PI < 4 or below A-line      -> SM / GM
  ///  - PI > 7 and on/above A-line  -> SC / GC
  ///  - 4 ≤ PI ≤ 7 (hatched zone)   -> SC-SM / GC-GM
  String uscsClassify(
    double pass200,
    double ll,
    double pl,
    double gravel, {
    double? cu,
    double? cc,
    bool organic = false,
  }) {
    final double pi = ll - pl;
    final double fines = pass200;

    // Guard: if fines are 100%, coarse fraction is 0 (cannot split gravel/sand)
    if ((100 - fines).abs() < 1e-9) {
      return "❌ Error: Fines percentage is 100, unable to classify gravel/sand.";
    }

    // Determine whether coarse fraction is gravel-dominant or sand-dominant
    final double coarse = 100 - fines;
    final double gravelPctOfCoarse = 100 * gravel / coarse;
    final bool isGravel = gravelPctOfCoarse > 50;

    // Gradation checks
    final bool wellGradedGravel =
        (cu != null && cu >= 4) && (cc != null && cc >= 1 && cc <= 3);
    final bool wellGradedSand =
        (cu != null && cu >= 6) && (cc != null && cc >= 1 && cc <= 3);

    // Fines < 50% (coarse-grained soils)
    if (fines < 50) {
      if (isGravel) {
        // GRAVELS
        if (fines < 5) {
          return wellGradedGravel ? "GW" : "GP";
        } else if (fines > 12) {
          // Gravels with fines > 12%
          if (pi < 4 || !checkALine(ll, pi)) return "GM";
          if (pi > 7 && checkALine(ll, pi)) return "GC";
          if (pi >= 4 && pi <= 7) return "GC-GM"; // hatched zone
          return "G${getFineType(ll, pi)}"; // fallback
        } else {
          // 5–12% fines -> dual with gradation
          return wellGradedGravel
              ? "GW-G${getFineType(ll, pi)}"
              : "GP-G${getFineType(ll, pi)}";
        }
      } else {
        // SANDS
        if (fines < 5) {
          return wellGradedSand ? "SW" : "SP";
        } else if (fines > 12) {
          // Sands with fines > 12%
          if (pi < 4 || !checkALine(ll, pi)) return "SM";
          if (pi > 7 && checkALine(ll, pi)) return "SC";
          if (pi >= 4 && pi <= 7) return "SC-SM"; // hatched zone
          return "S${getFineType(ll, pi)}"; // fallback
        } else {
          // 5–12% fines -> dual with gradation
          return wellGradedSand
              ? "SW-S${getFineType(ll, pi)}"
              : "SP-S${getFineType(ll, pi)}";
        }
      }
    }

    // Fines ≥ 50% (fine-grained soils: CL/ML/CH/MH and organics)
    if (organic) {
      return ll < 50 ? "OL" : "OH";
    } else {
      if (ll < 50) {
        if (pi > 7 && checkALine(ll, pi)) return "CL";
        if (pi < 4 && !checkALine(ll, pi)) return "ML";
        if (pi >= 4 && pi <= 7) return "CL-ML"; // hatched zone note
        // fallback
        return checkALine(ll, pi) ? "CL" : "ML";
      } else {
        return checkALine(ll, pi) ? "CH" : "MH";
      }
    }
  }

  // ---- Human-readable descriptions (your long mapping kept intact) --------
  void generateOutputText(String uscsSymbol, double gravel, double sand, double ll,
      bool organic, double pi, double pass200) {
    // (Your entire mapping from the original message is preserved.)
    if (uscsSymbol == "GW") {
      if (sand < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Well-graded Gravel)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Gravel with Sand)";
        });
      }
    } else if (uscsSymbol == "GP") {
      if (sand < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Poorly-graded Gravel)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Gravel with Sand)";
        });
      }
    } else if (uscsSymbol == "GW-GM") {
      if (sand < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Gravel with Silt)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Gravel with Silt and Sand)";
        });
      }
    } else if (uscsSymbol == "GW-GC") {
      if (sand < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Gravel with Clay)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Gravel with Clay and Sand)";
        });
      }
    } else if (uscsSymbol == "GP-GM") {
      if (sand < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Gravel with Silt)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Gravel with Silt and Sand)";
        });
      }
    } else if (uscsSymbol == "GP-GC") {
      if (sand < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Gravel with Clay)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Gravel with Clay and Sand)";
        });
      }
    } else if (uscsSymbol == "GM") {
      if (sand < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Silty Gravel)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Silty Gravel with Sand)";
        });
      }
    } else if (uscsSymbol == "GC") {
      if (sand < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Clayey Gravel)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Clayey Gravel with Sand)";
        });
      }
    } else if (uscsSymbol == "GC-GM") {
      if (sand < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Clayey Gravel with Silt)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Clayey Gravel with Silt and Sand)";
        });
      }
    } else if (uscsSymbol == "SW") {
      if (gravel < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Well-graded Sand)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Sand with Gravel)";
        });
      }
    } else if (uscsSymbol == "SP") {
      if (gravel < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Poorly-graded Sand)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Sand with Gravel)";
        });
      }
    } else if (uscsSymbol == "SW-SM") {
      if (gravel < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Sand with Silt)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Sand with Silt and Gravel)";
        });
      }
    } else if (uscsSymbol == "SW-SC") {
      if (gravel < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Sand with Clay)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Well-graded Sand with Clay and Gravel)";
        });
      }
    } else if (uscsSymbol == "SP-SM") {
      if (gravel < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Sand with Silt)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Sand with Silt and Gravel)";
        });
      }
    } else if (uscsSymbol == "SP-SC") {
      if (gravel < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Sand with Clay)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Poorly-graded Sand with Clay and Gravel)";
        });
      }
    } else if (uscsSymbol == "SM") {
      if (gravel < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Silty Sand)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Silty Sand with Gravel)";
        });
      }
    } else if (uscsSymbol == "SC") {
      if (gravel < 15) {
        setState(() {
          _uscsResult = "✅ USCS classification result: $uscsSymbol (Clayey Sand)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Clayey Sand with Gravel)";
        });
      }
    } else if (uscsSymbol == "SC-SM") {
      if (gravel < 15) {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Clayey Sand with Silt)";
        });
      } else {
        setState(() {
          _uscsResult =
              "✅ USCS classification result: $uscsSymbol (Clayey Sand with Silt and Gravel)";
        });
      }
    } else if (uscsSymbol == "CL") {
      if (100 - pass200 < 30) {
        if (100 - pass200 > 15) {
          setState(() {
            _uscsResult = "✅ USCS classification result: $uscsSymbol (Lean Clay)";
          });
        } else {
          if (sand >= gravel) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Lean Clay with Sand)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Lean Clay with Gravel)";
            });
          }
        }
      } else {
        if (sand >= gravel) {
          if (gravel < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Sandy Lean Clay)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Lean Clay with Gravel)";
            });
          }
        } else {
          if (sand < 15) {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Lean Clay)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Lean Clay with Sand)";
            });
          }
        }
      }
    } else if (uscsSymbol == "CL-ML") {
      if (100 - pass200 < 30) {
        if (100 - pass200 < 15) {
          setState(() {
            _uscsResult = "✅ USCS classification result: $uscsSymbol (Silty Clay)";
          });
        } else {
          if (sand >= gravel) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Silty Clay with Sand)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Silty Clay with Gravel)";
            });
          }
        }
      } else {
        if (sand >= gravel) {
          if (gravel < 15) {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Silty Clay)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Silty Clay with Gravel)";
            });
          }
        } else {
          if (sand < 15) {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Silty Clay)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Silty Clay with Sand)";
            });
          }
        }
      }
    } else if (uscsSymbol == "ML") {
      if (100 - pass200 < 30) {
        if (100 - pass200 < 15) {
          setState(() {
            _uscsResult = "✅ USCS classification result: $uscsSymbol (Silt)";
          });
        } else {
          if (sand >= gravel) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Silt with Sand)";
            });
          } else {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Silty with Gravel)";
            });
          }
        }
      } else {
        if (sand >= gravel) {
          if (gravel < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Sandy Silt)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Silt with Gravel)";
            });
          }
        } else {
          if (sand < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Gravelly Silt)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Silt with Sand)";
            });
          }
        }
      }
    } else if (uscsSymbol == "CH") {
      if (100 - pass200 < 30) {
        if (100 - pass200 < 15) {
          setState(() {
            _uscsResult = "✅ USCS classification result: $uscsSymbol (Fat Clay)";
          });
        } else {
          if (sand >= gravel) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Fat Clay with Sand)";
            });
          } else {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Fat Clay with Gravel)";
            });
          }
        }
      } else {
        if (sand >= gravel) {
          if (gravel < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Sandy Fat Clay)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Fat Clay with Gravel)";
            });
          }
        } else {
          if (sand < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Gravelly Fat Clay)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Fat Clay with Sand)";
            });
          }
        }
      }
    } else if (uscsSymbol == "MH") {
      if (100 - pass200 < 30) {
        if (100 - pass200 < 15) {
          setState(() {
            _uscsResult = "✅ USCS classification result: $uscsSymbol (Elastic Silt)";
          });
        } else {
          if (sand >= gravel) {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Elastic Silt with Sand)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Elastic Silt with Gravel)";
            });
          }
        }
      } else {
        if (sand >= gravel) {
          if (gravel < 15) {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Elastic Silt)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Sandy Elastic Silt with Gravel)";
            });
          }
        } else {
          if (sand < 15) {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Elastic Silt)";
            });
          } else {
            setState(() {
              _uscsResult =
                  "✅ USCS classification result: $uscsSymbol (Gravelly Elastic Silt with Sand)";
            });
          }
        }
      }
    } else if (uscsSymbol == "OL") {
      if (pi >= 4 && checkALine(ll, pi)) {
        if (100 - pass200 < 30) {
          if (100 - pass200 < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Organic Clay)";
            });
          } else {
            if (sand >= gravel) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Clay with Sand)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Clay with Gravel)";
              });
            }
          }
        } else {
          if (sand >= gravel) {
            if (gravel < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Clay)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Clay with Gravel)";
              });
            }
          } else {
            if (sand < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Clay)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Clay with Sand)";
              });
            }
          }
        }
      } else {
        if (100 - pass200 < 30) {
          if (100 - pass200 < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Organic Silt)";
            });
          } else {
            if (sand >= gravel) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Silt with Sand)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Silt with Gravel)";
              });
            }
          }
        } else {
          if (sand >= gravel) {
            if (gravel < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Silt)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Silt with Gravel)";
              });
            }
          } else {
            if (sand < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Silt)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Silt with Sand)";
              });
            }
          }
        }
      }
    } else if (uscsSymbol == "OH") {
      if (checkALine(ll, pi)) {
        if (100 - pass200 < 30) {
          if (100 - pass200 < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Organic Clay)";
            });
          } else {
            if (sand >= gravel) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Clay with Sand)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Clay with Gravel)";
              });
            }
          }
        } else {
          if (sand >= gravel) {
            if (gravel < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Clay)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Clay with Gravel)";
              });
            }
          } else {
            if (sand < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Clay)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Clay with Sand)";
              });
            }
          }
        }
      } else {
        if (100 - pass200 < 30) {
          if (100 - pass200 < 15) {
            setState(() {
              _uscsResult = "✅ USCS classification result: $uscsSymbol (Organic Silt)";
            });
          } else {
            if (sand >= gravel) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Silt with Sand)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Organic Silt with Gravel)";
              });
            }
          }
        } else {
          if (sand >= gravel) {
            if (gravel < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Silt)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Sandy Organic Silt with Gravel)";
              });
            }
          } else {
            if (sand < 15) {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Silt)";
              });
            } else {
              setState(() {
                _uscsResult =
                    "✅ USCS classification result: $uscsSymbol (Gravelly Organic Silt with Sand)";
              });
            }
          }
        }
      }
    }
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'USCS Soil Classification',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF87705c),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputField('Enter % passing No. 200 sieve:', _pass200Controller),
              _buildInputField('Enter Liquid Limit (LL):', _llController),
              _buildInputField('Enter Plastic Limit (PL):', _plController),
              _buildInputField('Enter % gravel:', _gravelController),

              // Organic toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Is the soil organic?'),
                  Switch(
                    value: _organic,
                    onChanged: (v) => setState(() => _organic = v),
                    activeColor: const Color(0xFF87705c),
                    inactiveThumbColor: Colors.grey,
                  ),
                ],
              ),

              _buildInputField('Enter Uniformity Coefficient (Cu, optional):', _cuController),
              _buildInputField('Enter Coefficient of Curvature (Cc, optional):', _ccController),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final pass200 = tryParse(_pass200Controller.text);
                  final ll = tryParse(_llController.text);
                  final pl = tryParse(_plController.text);
                  final gravel = tryParse(_gravelController.text);

                  if (pass200 == null || ll == null || pl == null || gravel == null) {
                    setState(() {
                      _uscsResult = "❌ Error: Missing required input (pass_200, LL, PL, or gravel).";
                    });
                    return;
                  }

                  final sand = 100 - pass200 - gravel;
                  final pi = ll - pl;
                  final cu = tryParse(_cuController.text);
                  final cc = tryParse(_ccController.text);

                  final symbol = uscsClassify(
                    pass200,
                    ll,
                    pl,
                    gravel,
                    cu: cu,
                    cc: cc,
                    organic: _organic,
                  );

                  generateOutputText(symbol, gravel, sand, ll, _organic, pi, pass200);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87705c),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Classify Soil'),
              ),

              const SizedBox(height: 16),
              Text(_warningMessage, style: const TextStyle(color: Colors.orange)),
              const SizedBox(height: 16),
              Text(_uscsResult, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
